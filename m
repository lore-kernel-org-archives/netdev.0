From: Andrea Parri <parri.andrea@gmail.com>
Subject: [PATCH] pkt_sched: sch_qfq: remove unused member of struct qfq_sched
Date: Tue, 14 Jul 2015 00:12:05 +0200
Message-ID: <1436825525-13506-1-git-send-email-parri.andrea@gmail.com>
Cc: Paolo Valente <paolo.valente@unimore.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andrea Parri <parri.andrea@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The member (u32) "num_active_agg" of struct qfq_sched has been unused
since its introduction in 462dbc9101acd38e92eda93c0726857517a24bbd
"pkt_sched: QFQ Plus: fair-queueing service at DRR cost" and (AFAICT)
there is no active plan to use it; this removes the member.

Signed-off-by: Andrea Parri <parri.andrea@gmail.com>
Acked-by: Paolo Valente <paolo.valente@unimore.it>
---
 net/sched/sch_qfq.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index b8d73bc..ffaeea6 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -186,7 +186,6 @@ struct qfq_sched {
 
 	u64			oldV, V;	/* Precise virtual times. */
 	struct qfq_aggregate	*in_serv_agg;   /* Aggregate being served. */
-	u32			num_active_agg; /* Num. of active aggregates */
 	u32			wsum;		/* weight sum */
 	u32			iwsum;		/* inverse weight sum */
 
-- 
1.9.1
