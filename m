From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 02/10] ip6tnl: rename rtnl functions for consistency
Date: Wed, 14 Nov 2012 16:13:59 +0100
Message-ID: <1352906047-11604-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34722 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964771Ab2KNPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:10 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions in this file start with ip6_tnl_.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9a7d8c7..6d35426 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1506,7 +1506,7 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static size_t ip6_get_size(const struct net_device *dev)
+static size_t ip6_tnl_get_size(const struct net_device *dev)
 {
 	return
 		/* IFLA_IPTUN_LINK */
@@ -1528,7 +1528,7 @@ static size_t ip6_get_size(const struct net_device *dev)
 		0;
 }
 
-static int ip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
+static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip6_tnl *tunnel = netdev_priv(dev);
 	struct __ip6_tnl_parm *parm = &tunnel->parms;
@@ -1554,8 +1554,8 @@ static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.kind		= "ip6tnl",
 	.maxtype	= IFLA_IPTUN_MAX,
 	.priv_size	= sizeof(struct ip6_tnl),
-	.get_size	= ip6_get_size,
-	.fill_info	= ip6_fill_info,
+	.get_size	= ip6_tnl_get_size,
+	.fill_info	= ip6_tnl_fill_info,
 };
 
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
-- 
1.7.12
