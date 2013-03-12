From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] bridge: netfilter: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 20:11:33 +0200
Message-ID: <1363111893-25146-1-git-send-email-silviupopescu1990@gmail.com>
Cc: bart.de.schuymer@pandora.be, pablo@netfilter.org, kaber@trash.net,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
readability.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
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
1.7.9.5

