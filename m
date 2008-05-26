From: Thomas Graf <tgraf@suug.ch>
Subject: [NET] route: Mark unused routing attributes as such
Date: Mon, 26 May 2008 13:30:24 +0200
Message-ID: <20080526113024.GX20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56798 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbYEZLaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 07:30:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also removes an unused policy entry for an attribute which is
only used in kernel->user direction.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/linux/rtnetlink.h
===================================================================
--- net-2.6.orig/include/linux/rtnetlink.h	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/include/linux/rtnetlink.h	2008-05-26 13:28:46.000000000 +0200
@@ -267,10 +267,10 @@
 	RTA_PREFSRC,
 	RTA_METRICS,
 	RTA_MULTIPATH,
-	RTA_PROTOINFO,
+	RTA_PROTOINFO, /* no longer used */
 	RTA_FLOW,
 	RTA_CACHEINFO,
-	RTA_SESSION,
+	RTA_SESSION, /* no longer used */
 	RTA_MP_ALGO, /* no longer used */
 	RTA_TABLE,
 	__RTA_MAX
Index: net-2.6/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_frontend.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/ipv4/fib_frontend.c	2008-05-26 13:28:47.000000000 +0200
@@ -506,7 +506,6 @@
 	[RTA_PREFSRC]		= { .type = NLA_U32 },
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
-	[RTA_PROTOINFO]		= { .type = NLA_U32 },
 	[RTA_FLOW]		= { .type = NLA_U32 },
 };
 
