From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/2] [iproute2] add man7 to subdirs list
Date: Fri, 11 Jan 2013 11:56:28 -0500
Message-ID: <1357923389-20114-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53900 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab3AKQxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 11:53:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The man dir misses the man7 as a subdir which means none of the pages
get installed.

URL: https://bugs.gentoo.org/451166
Reported-by: Marcin Miros=C5=82aw <bug@mejor.pl>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 man/Makefile      |  2 +-
 man/man7/Makefile | 13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)
 create mode 100644 man/man7/Makefile

diff --git a/man/Makefile b/man/Makefile
index 67fea05..9a60fa7 100644
--- a/man/Makefile
+++ b/man/Makefile
@@ -2,7 +2,7 @@ INSTALL=3Dinstall
 INSTALLDIR=3Dinstall -m 0755 -d
 INSTALLMAN=3Dinstall -m 0644
=20
-SUBDIRS =3D man3 man8
+SUBDIRS =3D man3 man7 man8
=20
 all:
 	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir; done
diff --git a/man/man7/Makefile b/man/man7/Makefile
new file mode 100644
index 0000000..ccfd839
--- /dev/null
+++ b/man/man7/Makefile
@@ -0,0 +1,13 @@
+MAN7PAGES =3D tc-hfsc.7
+
+all:
+
+distclean: clean
+
+clean:
+
+install:
+	$(INSTALLDIR) $(DESTDIR)$(MANDIR)/man7
+	$(INSTALLMAN) $(MAN7PAGES) $(DESTDIR)$(MANDIR)/man7
+
+.PHONY: install clean distclean
--=20
1.8.0.2
