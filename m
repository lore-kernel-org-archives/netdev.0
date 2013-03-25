From: pablo@netfilter.org
Subject: [PATCH 03/12] bridge: netfilter: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Mon, 25 Mar 2013 13:15:43 +0100
Message-ID: <1364213752-3934-4-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46494 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757120Ab3CYMQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:10 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
readability.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtable_broute.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 40d8258..70f656c 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -64,9 +64,7 @@ static int ebt_broute(struct sk_buff *skb)
 static int __net_init broute_net_init(struct net *net)
 {
 	net->xt.broute_table = ebt_register_table(net, &broute_table);
-	if (IS_ERR(net->xt.broute_table))
-		return PTR_ERR(net->xt.broute_table);
-	return 0;
+	return PTR_RET(net->xt.broute_table);
 }
 
 static void __net_exit broute_net_exit(struct net *net)
-- 
1.7.10.4
