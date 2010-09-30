From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net_sched: use __TCA_HTB_MAX and TCA_HTB_MAX
Date: Fri,  1 Oct 2010 00:17:44 +0800
Message-ID: <1285863464-5299-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58843 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495Ab0JHIFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 04:05:08 -0400
Received: by pwj4 with SMTP id 4so41067pwj.19
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 01:05:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/sch_htb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 4be8d04..87d9449 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1302,14 +1302,14 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct htb_class *cl = (struct htb_class *)*arg, *parent;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
-	struct nlattr *tb[TCA_HTB_RTAB + 1];
+	struct nlattr *tb[__TCA_HTB_MAX];
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
 	if (!opt)
 		goto failure;
 
-	err = nla_parse_nested(tb, TCA_HTB_RTAB, opt, htb_policy);
+	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy);
 	if (err < 0)
 		goto failure;
 
