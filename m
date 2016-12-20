From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net_sched: sch_netem: use rb_entry()
Date: Tue, 20 Dec 2016 22:02:16 +0800
Message-ID: <dc6e312e4e2ff3868d1791032c329477d27ba50b.1482204694.git.geliangtang@gmail.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        netem@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/sched/sch_netem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9f7b380..b7e4097 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -152,7 +152,7 @@ struct netem_skb_cb {
 
 static struct sk_buff *netem_rb_to_skb(struct rb_node *rb)
 {
-	return container_of(rb, struct sk_buff, rbnode);
+	return rb_entry(rb, struct sk_buff, rbnode);
 }
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
-- 
2.9.3
