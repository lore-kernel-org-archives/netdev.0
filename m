From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm] net/sched/sch_cbq.c: Shut up uninitialized variable
 warning
Date: Sun, 2 Sep 2007 07:00:11 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709020656050.20781@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41107 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933052AbXIBBRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 21:17:04 -0400
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


net/sched/sch_cbq.c: In function 'cbq_enqueue':
net/sched/sch_cbq.c:383: warning: 'ret' may be used uninitialized in this function

has been verified to be a bogus case. So let's shut it up.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 net/sched/sch_cbq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.23-rc4-mm1/net/sched/sch_cbq.c~fix	2007-09-02 06:45:08.000000000 +0530
+++ linux-2.6.23-rc4-mm1/net/sched/sch_cbq.c	2007-09-02 06:44:37.000000000 +0530
@@ -380,7 +380,7 @@ cbq_enqueue(struct sk_buff *skb, struct 
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	int len = skb->len;
-	int ret;
+	int uninitialized_var(ret);
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
 #ifdef CONFIG_NET_CLS_ACT
