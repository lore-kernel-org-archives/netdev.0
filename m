From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] act_police: rename tcf_act_police_locate() to tcf_act_police_init()
Date: Mon, 13 Jun 2016 10:47:44 -0700
Message-ID: <1465840064-7650-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34086 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423111AbcFMRru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:47:50 -0400
Received: by mail-pf0-f194.google.com with SMTP id 66so9200454pfy.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:47:49 -0700 (PDT)
In-Reply-To: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is just ->init(), rename it to make it obvious.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_police.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index ff34dd3..1e8ede3 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -115,9 +115,9 @@ static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 	[TCA_POLICE_RESULT]	= { .type = NLA_U32 },
 };
 
-static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
-				 struct nlattr *est, struct tc_action *a,
-				 int ovr, int bind)
+static int tcf_act_police_init(struct net *net, struct nlattr *nla,
+			       struct nlattr *est, struct tc_action *a,
+			       int ovr, int bind)
 {
 	int ret = 0, err;
 	struct nlattr *tb[TCA_POLICE_MAX + 1];
@@ -366,7 +366,7 @@ static struct tc_action_ops act_police_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
-	.init		=	tcf_act_police_locate,
+	.init		=	tcf_act_police_init,
 	.walk		=	tcf_act_police_walker,
 	.lookup		=	tcf_police_search,
 };
-- 
2.1.0
