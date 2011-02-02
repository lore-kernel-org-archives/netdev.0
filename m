From: kaber@trash.net
Subject: [PATCH 17/26] IPVS: use z modifier for sizeof() argument
Date: Thu,  3 Feb 2011 00:11:55 +0100
Message-ID: <1296688324-7830-18-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44722 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab1BBXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:34 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d889f4f..4d06617 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1887,7 +1887,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
-	printk(KERN_INFO "IPVS: Creating netns size=%lu id=%d\n",
+	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
 			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
 }
-- 
1.7.2.3

