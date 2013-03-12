From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] ipv4: netfilter: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 20:07:55 +0200
Message-ID: <1363111675-21457-1-git-send-email-silviupopescu1990@gmail.com>
Cc: pablo@netfilter.org, kaber@trash.net, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
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
 net/ipv4/netfilter/arptable_filter.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 79ca5e7..eadab1e 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -48,9 +48,7 @@ static int __net_init arptable_filter_net_init(struct net *net)
 	net->ipv4.arptable_filter =
 		arpt_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv4.arptable_filter))
-		return PTR_ERR(net->ipv4.arptable_filter);
-	return 0;
+	return PTR_RET(net->ipv4.arptable_filter);
 }
 
 static void __net_exit arptable_filter_net_exit(struct net *net)
-- 
1.7.9.5

