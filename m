From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: fix typo for initial_quantum
Date: Mon, 07 Oct 2013 12:50:18 -0700
Message-ID: <1381175418.12191.19.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:46854 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab3JGTuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:50:19 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so7548026pbc.32
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 12:50:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCA_FQ_INITIAL_QUANTUM should set q->initial_quantum

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a2fef8b..d8cb3b5 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -656,7 +656,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 		q->quantum = nla_get_u32(tb[TCA_FQ_QUANTUM]);
 
 	if (tb[TCA_FQ_INITIAL_QUANTUM])
-		q->quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
+		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
 
 	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
 		q->flow_default_rate = nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
