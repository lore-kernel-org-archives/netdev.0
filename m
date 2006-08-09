From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] net: drop unused elements from net_proto_family
Date: Wed, 09 Aug 2006 11:31:41 -0700
Message-ID: <20060809183349.354480139@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5568 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751188AbWHISkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:40:55 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Content-Disposition: inline; filename=family-trim.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Three values in net_proto_family are defined but never used.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.orig/include/linux/net.h	2006-08-09 11:14:51.000000000 -0700
+++ net-2.6/include/linux/net.h	2006-08-09 11:19:19.000000000 -0700
@@ -169,11 +169,6 @@
 struct net_proto_family {
 	int		family;
 	int		(*create)(struct socket *sock, int protocol);
-	/* These are counters for the number of different methods of
-	   each we support */
-	short		authentication;
-	short		encryption;
-	short		encrypt_net;
 	struct module	*owner;
 };
 

--

