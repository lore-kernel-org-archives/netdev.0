From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 6/8] Remove comments about hardcoded values.
Date: Mon, 29 Oct 2007 00:23:05 -0700
Message-ID: <1193642587-32657-7-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50321 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbXJ2HXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:14 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

None of these are true anymore (hooray!).

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |    8 --------
 net/sched/sch_sfq.c       |   13 +------------
 2 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 919af93..d754a3d 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -148,14 +148,6 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
-/*
- *  NOTE: limit, divisor and flows are hardwired to code at the moment.
- *
- *	limit=flows=128, divisor=1024;
- *
- *	The only reason for this is efficiency, it is possible
- *	to change these parameters in compile time.
- */
 
 /* RED section */
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index ca8716f..7b11086 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -62,18 +62,7 @@
 
 	We still need true WFQ for top level CSZ, but using WFQ
 	for the best effort traffic is absolutely pointless:
-	SFQ is superior for this purpose.
-
-	IMPLEMENTATION:
-	This implementation limits maximal queue length to 128;
-	maximal mtu to 2^15-1; number of hash buckets to 1024.
-	The only goal of this restrictions was that all data
-	fit into one 4K page :-). Struct sfq_sched_data is
-	organized in anti-cache manner: all the data for a bucket
-	are scattered over different locations. This is not good,
-	but it allowed me to put it into 4K.
-
-	It is easy to increase these values, but not in flight.  */
+	SFQ is superior for this purpose. */
 
 #define SFQ_DEPTH_DEFAULT	128
 #define SFQ_DIVISOR_DEFAULT	10
-- 
1.5.3.4

