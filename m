From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] net_sched: sfq: remove unused macro
Date: Mon,  8 Sep 2014 23:33:01 +0200
Message-ID: <1410211981-31081-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36717 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754629AbaIHVdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:33:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

not used anymore since ddecf0f
(net_sched: sfq: add optional RED on top of SFQ).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_sfq.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 1af2f73..211db90 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -310,11 +310,6 @@ static inline void slot_queue_add(struct sfq_slot *slot, struct sk_buff *skb)
 	slot->skblist_prev = skb;
 }
 
-#define	slot_queue_walk(slot, skb)		\
-	for (skb = slot->skblist_next;		\
-	     skb != (struct sk_buff *)slot;	\
-	     skb = skb->next)
-
 static unsigned int sfq_drop(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-- 
1.8.1.5
