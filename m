From: yegorslists@googlemail.com
Subject: [PATCH] rename configure.in to configure.ac
Date: Fri, 15 Mar 2013 16:05:46 +0100
Message-ID: <1363359946-7703-1-git-send-email-yegorslists@googlemail.com>
Cc: stephen@networkplumber.org, buytenh@gnu.org,
	Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hhlx01.visionsystems.de ([62.145.30.242]:46179 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab3COP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 11:29:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

Automake 1.14 will likely drop support for the long-deprecated
'configure.in' name for the Autoconf input file.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 configure.ac |   27 +++++++++++++++++++++++++++
 configure.in |   27 ---------------------------
 2 files changed, 27 insertions(+), 27 deletions(-)
 create mode 100644 configure.ac
 delete mode 100644 configure.in

diff --git a/configure.ac b/configure.ac
new file mode 100644
index 0000000..5e3f89b
--- /dev/null
+++ b/configure.ac
@@ -0,0 +1,27 @@
+dnl Process this file with autoconf to produce a configure script.
+AC_INIT(bridge-utils, 1.5)
+AC_CONFIG_HEADERS(libbridge/config.h)
+
+AC_ARG_WITH( linux-headers, [  --with-linux-headers     Location of the linux headers to use], 
+    KERNEL_HEADERS=$withval, KERNEL_HEADERS="/usr/src/linux/include")
+
+dnl Checks for programs.
+AC_PROG_CC
+AC_PROG_INSTALL
+AC_PROG_RANLIB
+
+dnl Checks for header files.
+AC_HEADER_STDC
+AC_CHECK_HEADERS(sys/ioctl.h sys/time.h)
+
+dnl Checks for typedefs, structures, and compiler characteristics.
+AC_C_CONST
+AC_HEADER_TIME
+
+dnl Checks for library functions.
+AC_CHECK_FUNCS(gethostname socket strdup uname)
+AC_CHECK_FUNCS(if_nametoindex if_indextoname)
+
+AC_SUBST(KERNEL_HEADERS)
+
+AC_OUTPUT(doc/Makefile libbridge/Makefile brctl/Makefile Makefile bridge-utils.spec)
diff --git a/configure.in b/configure.in
deleted file mode 100644
index 5e3f89b..0000000
--- a/configure.in
+++ /dev/null
@@ -1,27 +0,0 @@
-dnl Process this file with autoconf to produce a configure script.
-AC_INIT(bridge-utils, 1.5)
-AC_CONFIG_HEADERS(libbridge/config.h)
-
-AC_ARG_WITH( linux-headers, [  --with-linux-headers     Location of the linux headers to use], 
-    KERNEL_HEADERS=$withval, KERNEL_HEADERS="/usr/src/linux/include")
-
-dnl Checks for programs.
-AC_PROG_CC
-AC_PROG_INSTALL
-AC_PROG_RANLIB
-
-dnl Checks for header files.
-AC_HEADER_STDC
-AC_CHECK_HEADERS(sys/ioctl.h sys/time.h)
-
-dnl Checks for typedefs, structures, and compiler characteristics.
-AC_C_CONST
-AC_HEADER_TIME
-
-dnl Checks for library functions.
-AC_CHECK_FUNCS(gethostname socket strdup uname)
-AC_CHECK_FUNCS(if_nametoindex if_indextoname)
-
-AC_SUBST(KERNEL_HEADERS)
-
-AC_OUTPUT(doc/Makefile libbridge/Makefile brctl/Makefile Makefile bridge-utils.spec)
-- 
1.7.7
