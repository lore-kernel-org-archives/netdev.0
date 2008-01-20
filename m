From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/09]: sch_ingress: remove unused inner qdisc
Date: Sun, 20 Jan 2008 15:32:34 +0100 (MET)
Message-ID: <20080120143136.27801.67649.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbYATOcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:36 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bb582f29b1f403d0df8a4a54daca89eafd2bfb69
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:07 2008 +0100

    [NET_SCHED]: sch_ingress: remove unused inner qdisc
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index cb8ba8b..d803cd1 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -27,7 +27,6 @@ static int nf_registered;
 #endif
 
 struct ingress_qdisc_data {
-	struct Qdisc		*q;
 	struct tcf_proto	*filter_list;
 };
 
@@ -178,8 +177,6 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 
 static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct ingress_qdisc_data *p = qdisc_priv(sch);
-
 	/* Make sure either netfilter or preferably CLS_ACT is
 	 * compiled in */
 #ifndef CONFIG_NET_CLS_ACT
@@ -202,7 +199,6 @@ static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 	}
 #endif
 #endif
-	p->q = &noop_qdisc;
 	return 0;
 }
 
