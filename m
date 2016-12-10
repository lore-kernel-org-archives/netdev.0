From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipvs: remove an annoying printk in netns init
Date: Fri,  9 Dec 2016 21:09:59 -0800
Message-ID: <1481346600-25335-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34530 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbcLJFKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 00:10:19 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so4323174pgc.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 21:10:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At most it is used for debugging purpose, but I don't think
it is even useful for debugging, just remove it.

Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2c1b498..febc7f3 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2231,8 +2231,6 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_sync_net_init(ipvs) < 0)
 		goto sync_fail;
 
-	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
-			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
 /*
  * Error handling
-- 
2.5.5
