From: kaber@trash.net
Subject: [PATCH 18/26] IPVS: remove duplicate initialisation or rs_table
Date: Thu,  3 Feb 2011 00:11:56 +0100
Message-ID: <1296688324-7830-19-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44718 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab1BBXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:34 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 98df59a..d7c2fa8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3515,9 +3515,6 @@ int __net_init __ip_vs_control_init(struct net *net)
 	}
 	spin_lock_init(&ipvs->tot_stats->lock);
 
-	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
-		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
-
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
 	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
-- 
1.7.2.3

