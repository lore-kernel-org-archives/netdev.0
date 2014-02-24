From: Andrey Mazo <mazo@telum.ru>
Subject: [PATCH 3/4] bridge-utils: AC_OUTPUT should be used without arguments
Date: Mon, 24 Feb 2014 14:56:45 +0400
Message-ID: <1393239406-8504-4-git-send-email-mazo@telum.ru>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Cc: Andrey Mazo <mazo@telum.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:50890 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbaBXLCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 06:02:34 -0500
In-Reply-To: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a result of autoupdate-2.69 run and fixes the following
warning:
configure.ac:27: warning: AC_OUTPUT should be used without arguments.
configure.ac:27: You should run autoupdate.

Signed-off-by: Andrey Mazo <mazo@telum.ru>
---
 configure.ac | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 5e3f89b..096f017 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,5 +1,5 @@
 dnl Process this file with autoconf to produce a configure script.
-AC_INIT(bridge-utils, 1.5)
+AC_INIT([bridge-utils],[1.5])
 AC_CONFIG_HEADERS(libbridge/config.h)
 
 AC_ARG_WITH( linux-headers, [  --with-linux-headers     Location of the linux headers to use], 
@@ -24,4 +24,5 @@ AC_CHECK_FUNCS(if_nametoindex if_indextoname)
 
 AC_SUBST(KERNEL_HEADERS)
 
-AC_OUTPUT(doc/Makefile libbridge/Makefile brctl/Makefile Makefile bridge-utils.spec)
+AC_CONFIG_FILES([doc/Makefile libbridge/Makefile brctl/Makefile Makefile bridge-utils.spec])
+AC_OUTPUT
-- 
1.8.4.5
