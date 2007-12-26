From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange Panic (Deadlock)
Date: Wed, 26 Dec 2007 19:56:42 +0100
Message-ID: <20071226185642.GB3061@ami.dom.local>
References: <476FCC41.8070202@bigtelecom.ru> <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru> <47701542.9010806@gmail.com> <4770C956.5040409@bigtelecom.ru> <20071226185411.GA3061@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:29104 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbXLZSyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 13:54:47 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1513928ugc.16
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 10:54:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071226185411.GA3061@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 26, 2007 at 07:54:11PM +0100, Jarek Poplawski wrote:
...

[PATCH 2/3] (for testing only)
---

diff -Nurp linux-2.6.23.12-/net/sched/sch_sfq.c linux-2.6.23.12+/net/sched/sch_sfq.c
--- linux-2.6.23.12-/net/sched/sch_sfq.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23.12+/net/sched/sch_sfq.c	2007-12-26 12:45:06.000000000 +0100
@@ -457,7 +457,7 @@ static int sfq_init(struct Qdisc *sch, s
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	del_timer(&q->perturb_timer);
+	del_timer_sync(&q->perturb_timer);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
