From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: use src+dst for rss hashing
Date: Fri, 04 Dec 2009 21:00:15 +0100
Message-ID: <4B196A4F.5040408@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1994 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757258AbZLDUAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 15:00:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more effective rss hash by default (src + dst, rather than just src).

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2009-12-04 20:10:48.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-12-04 20:57:15.000000000 +0100
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.1-1.451"
+#define MYRI10GE_VERSION_STR "1.5.1-1.453"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -347,7 +347,7 @@
 module_param(myri10ge_max_slices, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_max_slices, "Max tx/rx queues");
 
-static int myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
+static int myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT;
 module_param(myri10ge_rss_hash, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_rss_hash, "Type of RSS hashing to do");
 


