From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/21] netfilter: xt_MARK: Add ARP support
Date: Mon, 18 May 2015 18:25:22 +0200
Message-ID: <1431966324-4494-20-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhang Chunyu <zhangcy@cn.fujitsu.com>

Add arpt_MARK to xt_mark.

The corresponding userspace update is available at:

http://git.netfilter.org/arptables/commit/?id=4bb2f8340783fd3a3f70aa6f8807428a280f8474

Signed-off-by: Zhang Chunyu <zhangcy@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_mark.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 2334523..ebd41dc 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -23,6 +23,7 @@ MODULE_ALIAS("ipt_mark");
 MODULE_ALIAS("ip6t_mark");
 MODULE_ALIAS("ipt_MARK");
 MODULE_ALIAS("ip6t_MARK");
+MODULE_ALIAS("arpt_MARK");
 
 static unsigned int
 mark_tg(struct sk_buff *skb, const struct xt_action_param *par)
-- 
1.7.10.4

