From: Thomas Graf <tgraf@suug.ch>
Subject: [NET] route: Mark unused route cache flags as such.
Date: Mon, 26 May 2008 13:28:59 +0200
Message-ID: <20080526112858.GW20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56785 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753596AbYEZL2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 07:28:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also removes an obsolete check for the unused flag RTCF_MASQ.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/route.c
===================================================================
--- net-2.6.orig/net/ipv4/route.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/ipv4/route.c	2008-05-26 13:27:04.000000000 +0200
@@ -1792,7 +1792,7 @@
 	if (err)
 		flags |= RTCF_DIRECTSRC;
 
-	if (out_dev == in_dev && err && !(flags & RTCF_MASQ) &&
+	if (out_dev == in_dev && err &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
 	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
 		flags |= RTCF_DOREDIRECT;
Index: net-2.6/include/linux/in_route.h
===================================================================
--- net-2.6.orig/include/linux/in_route.h	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/include/linux/in_route.h	2008-05-26 13:27:04.000000000 +0200
@@ -10,19 +10,19 @@
 #define RTCF_NOPMTUDISC RTM_F_NOPMTUDISC
 
 #define RTCF_NOTIFY	0x00010000
-#define RTCF_DIRECTDST	0x00020000
+#define RTCF_DIRECTDST	0x00020000 /* unused */
 #define RTCF_REDIRECTED	0x00040000
-#define RTCF_TPROXY	0x00080000
+#define RTCF_TPROXY	0x00080000 /* unused */
 
-#define RTCF_FAST	0x00200000
-#define RTCF_MASQ	0x00400000
-#define RTCF_SNAT	0x00800000
+#define RTCF_FAST	0x00200000 /* unused */
+#define RTCF_MASQ	0x00400000 /* unused */
+#define RTCF_SNAT	0x00800000 /* unused */
 #define RTCF_DOREDIRECT 0x01000000
 #define RTCF_DIRECTSRC	0x04000000
 #define RTCF_DNAT	0x08000000
 #define RTCF_BROADCAST	0x10000000
 #define RTCF_MULTICAST	0x20000000
-#define RTCF_REJECT	0x40000000
+#define RTCF_REJECT	0x40000000 /* unused */
 #define RTCF_LOCAL	0x80000000
 
 #define RTCF_NAT	(RTCF_DNAT|RTCF_SNAT)
