class Evince < Formula
  desc "GNOME document viewer"
  homepage "https://wiki.gnome.org/Apps/Evince"
  url "https://download.gnome.org/sources/evince/3.36/evince-3.36.1.tar.xz"
  sha256 "8cb8bfd358a02d8edba51114548e98154321e0895bf379a5bb336a458d594bd7"

  bottle do
    sha256 "37631b73c322e2301e5bb851b7845843244e5aedd62e7eb69734d568fce42e9a" => :catalina
    sha256 "bb4355df7df850fdff3540267050c95b9c078ac04363d47e853fcd8fcbc33b3a" => :mojave
    sha256 "76b38830fcf331cab2f471b69a8c7a4602c4267193fd6bce7885a238abb36c3a" => :high_sierra
  end

  depends_on "appstream-glib" => :build
  depends_on "gobject-introspection" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "djvulibre"
  depends_on "gspell"
  depends_on "gtk+3"
  depends_on "hicolor-icon-theme"
  depends_on "libarchive"
  depends_on "libsecret"
  depends_on "libspectre"
  depends_on "libxml2"
  depends_on "poppler"
  depends_on "python@3.8"

  def install
    ENV["GETTEXTDATADIR"] = "#{Formula["appstream-glib"].opt_share}/gettext"

    # Fix build failure "ar: illegal option -- D"
    # Reported 15 Sep 2017 https://bugzilla.gnome.org/show_bug.cgi?id=787709
    inreplace "configure", "AR_FLAGS=crD", "AR_FLAGS=r"

    # Add MacOS mime-types to the list of supported comic book archive mime-types
    # Submitted upstream at https://gitlab.gnome.org/GNOME/evince/merge_requests/157
    inreplace "configure", "COMICS_MIME_TYPES=\"",
      "COMICS_MIME_TYPES=\"application/x-rar;application/zip;application/x-cb7;" \
                          "application/x-7z-comperssed;application/x-tar;"

    # forces use of gtk3-update-icon-cache instead of gtk-update-icon-cache. No bugreport should
    # be filed for this since it only occurs because Homebrew renames gtk+3's gtk-update-icon-cache
    # to gtk3-update-icon-cache in order to avoid a collision between gtk+ and gtk+3.
    inreplace "data/Makefile.in", "gtk-update-icon-cache", "gtk3-update-icon-cache"

    xy = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python#{xy}/site-packages"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-nautilus",
                          "--disable-schemas-compile",
                          "--enable-introspection",
                          "--enable-djvu",
                          "--disable-browser-plugin"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/evince --version")
  end
end
