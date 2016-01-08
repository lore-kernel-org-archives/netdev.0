From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/17] netfilter: nfnetlink_queue: just returns error for unknown command
Date: Fri,  8 Jan 2016 15:02:12 +0100
Message-ID: <1452261737-7475-13-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch stops processing options for unknown command.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 57951ce..c1f6df4 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1182,7 +1182,7 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 			break;
 		default:
 			ret = -ENOTSUPP;
-			break;
+			goto err_out_unlock;
 		}
 	}
 
-- 
2.1.4

