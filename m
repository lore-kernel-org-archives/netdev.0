From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/17] netfilter: nfnetlink_queue: don't handle options after unbind
Date: Fri,  8 Jan 2016 15:02:11 +0100
Message-ID: <1452261737-7475-12-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch stops processing after destroying a queue instance.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index fe360f7..57951ce 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1176,7 +1176,7 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 				goto err_out_unlock;
 			}
 			instance_destroy(q, queue);
-			break;
+			goto err_out_unlock;
 		case NFQNL_CFG_CMD_PF_BIND:
 		case NFQNL_CFG_CMD_PF_UNBIND:
 			break;
-- 
2.1.4

