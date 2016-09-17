From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/5] pie: use qdisc_dequeue_head wrapper
Date: Sun, 18 Sep 2016 00:57:30 +0200
Message-ID: <1474153054-9059-2-git-send-email-fw@strlen.de>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51382 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754719AbcIQW52 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:28 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesn't change generated code.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_pie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index a570b0b..d976d74 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -511,7 +511,7 @@ static int pie_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 static struct sk_buff *pie_qdisc_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
-	skb = __qdisc_dequeue_head(sch, &sch->q);
+	skb = qdisc_dequeue_head(sch);
 
 	if (!skb)
 		return NULL;
-- 
2.7.3
