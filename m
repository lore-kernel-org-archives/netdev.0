From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 4/6] net_sched: add space around '>' and before '('
Date: Tue, 10 Dec 2013 20:55:32 +0800
Message-ID: <1386680134-85452-5-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5177 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3LJMzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:47 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spaces required around that '>' (ctx:VxV) and
before the open parenthesis '('.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_cbq.c   | 3 ++-
 net/sched/sch_netem.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 7a42c81..d5a8a4b 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1058,7 +1058,8 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 				cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
 					q->quanta[prio];
 			}
-			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
+			if (cl->quantum <= 0 ||
+			    cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
 				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
 					   cl->common.classid, cl->quantum);
 				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bccd52b..f3befd6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -729,7 +729,7 @@ static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
 	nla_for_each_nested(la, attr, rem) {
 		u16 type = nla_type(la);
 
-		switch(type) {
+		switch (type) {
 		case NETEM_LOSS_GI: {
 			const struct tc_netem_gimodel *gi = nla_data(la);
 
-- 
1.8.0
