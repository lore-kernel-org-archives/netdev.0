From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 1/4] net_sched: gred: correct comment about qavg calculation in RIO mode
Date: Thu, 13 Sep 2012 11:22:32 -0400
Message-ID: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Osler <brosler@cisco.com>, Cyril Chemparathy <cyril@ti.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:49829 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab2IMPnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 11:43:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index e901583..fca73cd 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -176,7 +176,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->tc_index = (skb->tc_index & ~GRED_VQ_MASK) | dp;
 	}
 
-	/* sum up all the qaves of prios <= to ours to get the new qave */
+	/* sum up all the qaves of prios < ours to get the new qave */
 	if (!gred_wred_mode(t) && gred_rio_mode(t)) {
 		int i;
 
-- 
1.7.4.1
