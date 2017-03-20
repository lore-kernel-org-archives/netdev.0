From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/22] ipvs: remove an annoying printk in netns init
Date: Mon, 20 Mar 2017 11:08:44 +0100
Message-ID: <1490004530-9128-17-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754037AbdCTKJl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9A16B52332
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 89EF8DA870
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 53C03DA7E9
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:13 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

At most it is used for debugging purpose, but I don't think
it is even useful for debugging, just remove it.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index db40050f8785..9aaa49025cdc 100644
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
2.1.4
