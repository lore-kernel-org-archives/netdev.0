From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/6] [IPv4] nl_fib_lookup: Rename fl_fwmark to fl_mark
Date: Thu, 09 Nov 2006 12:27:38 +0100
Message-ID: <20061109113245.708508099@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:6864 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965248AbWKILdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:46 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=cleanup_fib_result
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the sake of consistency.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/ip_fib.h
===================================================================
--- net-2.6.20.orig/include/net/ip_fib.h	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/include/net/ip_fib.h	2006-11-08 16:12:34.000000000 +0100
@@ -115,7 +115,7 @@
 
 struct fib_result_nl {
 	__be32		fl_addr;   /* To be looked up*/
-	u32		fl_fwmark; 
+	u32		fl_mark;
 	unsigned char	fl_tos;
 	unsigned char   fl_scope;
 	unsigned char   tb_id_in;
Index: net-2.6.20/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_frontend.c	2006-11-08 16:12:32.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_frontend.c	2006-11-08 16:12:34.000000000 +0100
@@ -768,7 +768,7 @@
 {
 	
 	struct fib_result       res;
-	struct flowi            fl = { .mark = frn->fl_fwmark,
+	struct flowi            fl = { .mark = frn->fl_mark,
 				       .nl_u = { .ip4_u = { .daddr = frn->fl_addr,
 							    .tos = frn->fl_tos,
 							    .scope = frn->fl_scope } } };

--

