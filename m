From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH v2] net_sched: red: Make minor corrections to comments
Date: Mon, 16 Apr 2012 09:17:22 -0400
Message-ID: <1334582242-3754-1-git-send-email-david.ward@ll.mit.edu>
References: <4F8C193A.5090806@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:60020 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619Ab2DPNUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 09:20:46 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id q3GDKcwr015996 for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 09:20:45 -0400
In-Reply-To: <4F8C193A.5090806@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/net/red.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/red.h b/include/net/red.h
index 77d4c37..ef46058 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -245,7 +245,7 @@ static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms
 	 *
 	 * dummy packets as a burst after idle time, i.e.
 	 *
-	 * 	p->qavg *= (1-W)^m
+	 * 	v->qavg *= (1-W)^m
 	 *
 	 * This is an apparently overcomplicated solution (f.e. we have to
 	 * precompute a table to make this calculation in reasonable time)
@@ -279,7 +279,7 @@ static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p
 						       unsigned int backlog)
 {
 	/*
-	 * NOTE: p->qavg is fixed point number with point at Wlog.
+	 * NOTE: v->qavg is fixed point number with point at Wlog.
 	 * The formula below is equvalent to floating point
 	 * version:
 	 *
@@ -390,7 +390,7 @@ static inline void red_adaptative_algo(struct red_parms *p, struct red_vars *v)
 	if (red_is_idling(v))
 		qavg = red_calc_qavg_from_idle_time(p, v);
 
-	/* p->qavg is fixed point number with point at Wlog */
+	/* v->qavg is fixed point number with point at Wlog */
 	qavg >>= p->Wlog;
 
 	if (qavg > p->target_max && p->max_P <= MAX_P_MAX)
-- 
1.7.1
