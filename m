From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 3/6] net_sched: change "foo* bar" to "foo *bar"
Date: Tue, 10 Dec 2013 20:55:31 +0800
Message-ID: <1386680134-85452-4-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5189 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168Ab3LJMzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:49 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"foo* bar" or "foo * bar" should be "foo *bar".

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/cls_u32.c     | 2 +-
 net/sched/sch_generic.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index eb07a1e..59e546c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -352,7 +352,7 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	return 0;
 }
 
-static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode* key)
+static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
 	struct tc_u_knode **kp;
 	struct tc_u_hnode *ht = key->ht_up;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 922a094..6a91d7d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -338,13 +338,13 @@ EXPORT_SYMBOL(netif_carrier_off);
    cheaper.
  */
 
-static int noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
+static int noop_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 {
 	kfree_skb(skb);
 	return NET_XMIT_CN;
 }
 
-static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
+static struct sk_buff *noop_dequeue(struct Qdisc *qdisc)
 {
 	return NULL;
 }
-- 
1.8.0
