From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 15/16] [XFRM] netlink: Remove dependency on rtnetlink
Date: Wed, 22 Aug 2007 16:55:53 +0200
Message-ID: <20070822145631.932930745@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56974 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759394AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_remove_rtnetlink_include
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:36:59.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:37:18.000000000 +0200
@@ -19,7 +19,6 @@
 #include <linux/string.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 #include <linux/init.h>

-- 

