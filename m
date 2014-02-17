From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] sch_netem: replace magic numbers with enumerate in get_loss_clg
Date: Mon, 17 Feb 2014 16:48:21 +0800
Message-ID: <1392626901-15096-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:10100 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaBQIsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:48:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace two magic numbers which intialize clgstate::state.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 4fced67..f1669a00 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -752,7 +752,7 @@ static int get_loss_clg(struct netem_sched_data *q, const struct nlattr *attr)
 
 			q->loss_model = CLG_4_STATES;
 
-			q->clg.state = 1;
+			q->clg.state = TX_IN_GAP_PERIOD;
 			q->clg.a1 = gi->p13;
 			q->clg.a2 = gi->p31;
 			q->clg.a3 = gi->p32;
@@ -770,7 +770,7 @@ static int get_loss_clg(struct netem_sched_data *q, const struct nlattr *attr)
 			}
 
 			q->loss_model = CLG_GILB_ELL;
-			q->clg.state = 1;
+			q->clg.state = GOOD_STATE;
 			q->clg.a1 = ge->p;
 			q->clg.a2 = ge->r;
 			q->clg.a3 = ge->h;
-- 
1.8.0
