From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 09/10] sit: rename rtnl functions for consistency
Date: Wed, 14 Nov 2012 16:14:06 +0100
Message-ID: <1352906047-11604-10-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34757 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964812Ab2KNPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:12 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions in this file start with ipip6_.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 28f56ee..28c1b82 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1216,7 +1216,7 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static size_t sit_get_size(const struct net_device *dev)
+static size_t ipip6_get_size(const struct net_device *dev)
 {
 	return
 		/* IFLA_IPTUN_LINK */
@@ -1236,7 +1236,7 @@ static size_t sit_get_size(const struct net_device *dev)
 		0;
 }
 
-static int sit_fill_info(struct sk_buff *skb, const struct net_device *dev)
+static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct ip_tunnel_parm *parm = &tunnel->parms;
@@ -1260,8 +1260,8 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.kind		= "sit",
 	.maxtype	= IFLA_IPTUN_MAX,
 	.priv_size	= sizeof(struct ip_tunnel),
-	.get_size	= sit_get_size,
-	.fill_info	= sit_fill_info,
+	.get_size	= ipip6_get_size,
+	.fill_info	= ipip6_fill_info,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
-- 
1.7.12
