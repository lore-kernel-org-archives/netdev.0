From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] net: removes unnecessary dependencies for
	net_namespace.h
Date: Mon, 3 Dec 2007 12:12:00 +0300
Message-ID: <20071203091200.GA20442@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net,
	xemul@openvz.org, ebiederm@xmission.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:61554 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751754AbXLCJLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 04:11:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some unneeded includes for net_namespace.h to speed up
compilation.

Signed-off-by: Denis V. Lunev <den@openvz.org>

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f285de6..28b7f25 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -2,7 +2,6 @@
 #define __NET_PKT_CLS_H
 
 #include <linux/pkt_cls.h>
-#include <net/net_namespace.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 43e3cd9..a04e361 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -57,7 +57,6 @@
 #include <asm/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
-#include <net/net_namespace.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -95,6 +94,7 @@ typedef struct {
 
 struct sock;
 struct proto;
+struct net;
 
 /**
  *	struct sock_common - minimal network layer representation of sockets
