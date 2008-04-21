From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make icmp_sk_init() static
Date: Mon, 21 Apr 2008 11:48:45 +0300
Message-ID: <20080421084845.GR26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41037 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756703AbYDUItO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:49:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global icmp_sk_init() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
d163a44e24881d5e960bf9bdc1819ba8ccd15555 diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f064031..fee171e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1144,7 +1144,7 @@ static void __net_exit icmp_sk_exit(struct net *net)
 	net->ipv4.icmp_sk = NULL;
 }
 
-int __net_init icmp_sk_init(struct net *net)
+static int __net_init icmp_sk_init(struct net *net)
 {
 	int i, err;
 
