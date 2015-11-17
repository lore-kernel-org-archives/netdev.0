From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: [iproute PATCH] misc/Makefile: use PKG_CONFIG
Date: Tue, 17 Nov 2015 16:08:00 +0200
Message-ID: <1447769280-11421-1-git-send-email-aaro.koskinen@nokia.com>
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>
To: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:43761 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbKQOPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PKG_CONFIG from Config - it works better when cross-compiling.

Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
---
 misc/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/Makefile b/misc/Makefile
index 389c1b0..f50e740 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -10,8 +10,8 @@ ifeq ($(HAVE_BERKELEY_DB),y)
 endif
 
 ifeq ($(HAVE_SELINUX),y)
-	LDLIBS += $(shell pkg-config --libs libselinux)
-	CFLAGS += $(shell pkg-config --cflags libselinux) -DHAVE_SELINUX
+	LDLIBS += $(shell $(PKG_CONFIG) --libs libselinux)
+	CFLAGS += $(shell $(PKG_CONFIG) --cflags libselinux) -DHAVE_SELINUX
 endif
 
 ifeq ($(IP_CONFIG_SETNS),y)
-- 
2.1.4
