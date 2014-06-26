From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: fix some typos in comment
Date: Thu, 26 Jun 2014 15:56:31 +0800
Message-ID: <1403769391-15222-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47352 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbaFZH4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 371121057607e3127e19b3fa094330181b5b031e("net:
QDISC_STATE_RUNNING dont need atomic bit ops") the
__QDISC_STATE_RUNNING is renamed to __QDISC___STATE_RUNNING,
but the old names existing in comment are not replaced with
the new name completely.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/dev.c          |    4 ++--
 net/sched/sch_generic.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a04b12f..de97741 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2738,8 +2738,8 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
-	 * This permits __QDISC_STATE_RUNNING owner to get the lock more often
-	 * and dequeue packets faster.
+	 * This permits __QDISC___STATE_RUNNING owner to get the lock more
+	 * often and dequeue packets faster.
 	 */
 	contended = qdisc_is_running(q);
 	if (unlikely(contended))
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e1543b0..fc04fe9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -108,7 +108,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 
 /*
  * Transmit one skb, and handle the return status as required. Holding the
- * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
+ * __QDISC___STATE_RUNNING bit guarantees that only one CPU can execute this
  * function.
  *
  * Returns to the caller:
@@ -156,7 +156,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 /*
  * NOTE: Called under qdisc_lock(q) with locally disabled BH.
  *
- * __QDISC_STATE_RUNNING guarantees only one CPU can process
+ * __QDISC___STATE_RUNNING guarantees only one CPU can process
  * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
  * this queue.
  *
-- 
1.7.9.5
