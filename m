From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] [PKT_SCHED] HTB: Add missing semicolon to fix compilation
Date: Sat, 15 Jul 2006 09:36:33 -0700
Message-ID: <adairlyrfji.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:56070 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1750717AbWGOQgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 12:36:36 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit b3a6251915df9e3d80d4a0d32bd8d24223906688, "[PKT_SCHED] HTB:
initialize upper bound properly", broke my compile because the new
line it added was missing a final semicolon.

Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Roland Dreier <rolandd@cisco.com>

---

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index cd0a973..cc5f339 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1601,7 +1601,7 @@ #endif
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60) /* 1min */
+		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60); /* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
