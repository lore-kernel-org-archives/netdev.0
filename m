From: kaber@trash.net
Subject: [PATCH 4/7] netfilter: ipvs: fix compiler warnings
Date: Mon, 31 Jan 2011 21:10:17 +0100
Message-ID: <1296504620-820-5-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59944 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1AaUKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 15:10:34 -0500
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Fix compiler warnings when IP_VS_DBG() isn't defined.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f36a84f..d889f4f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct net *net)
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
-	IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->gen);
+	IP_VS_DBG(10, "ipvs netns %d released\n", net_ipvs(net)->gen);
 }
 
 static struct pernet_operations ipvs_core_ops = {
-- 
1.7.2.3

