From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 3/5] net_sched: Use default action lookup functions
Date: Wed,  4 Dec 2013 09:26:54 -0500
Message-ID: <1386167216-30281-4-git-send-email-jhs@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36404 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab3LDO1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:40 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so26195052iej.40
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:40 -0800 (PST)
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_csum.c   |    1 -
 net/sched/act_gact.c   |    1 -
 net/sched/act_ipt.c    |    2 --
 net/sched/act_mirred.c |    1 -
 net/sched/act_nat.c    |    1 -
 net/sched/act_pedit.c  |    1 -
 net/sched/act_police.c |    1 -
 7 files changed, 8 deletions(-)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 3a4c0ca..4225a93 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -585,7 +585,6 @@ static struct tc_action_ops act_csum_ops = {
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
 	.cleanup	= tcf_csum_cleanup,
-	.lookup		= tcf_hash_search,
 	.init		= tcf_csum_init,
 	.walk		= tcf_generic_walker
 };
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index fd2b3cf..15851da 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -206,7 +206,6 @@ static struct tc_action_ops act_gact_ops = {
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
 	.cleanup	=	tcf_gact_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_gact_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 60d88b6..1d3e191 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -298,7 +298,6 @@ static struct tc_action_ops act_ipt_ops = {
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_ipt_init,
 	.walk		=	tcf_generic_walker
 };
@@ -312,7 +311,6 @@ static struct tc_action_ops act_xt_ops = {
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_ipt_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 977c10e..6cb16ec 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -271,7 +271,6 @@ static struct tc_action_ops act_mirred_ops = {
 	.act		=	tcf_mirred,
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_mirred_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 876f0ef..30c13de 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -308,7 +308,6 @@ static struct tc_action_ops act_nat_ops = {
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
 	.cleanup	=	tcf_nat_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_nat_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 7ed78c9..ab4fc56 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -243,7 +243,6 @@ static struct tc_action_ops act_pedit_ops = {
 	.act		=	tcf_pedit,
 	.dump		=	tcf_pedit_dump,
 	.cleanup	=	tcf_pedit_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_pedit_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 272d8e9..16a62c3 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -407,7 +407,6 @@ static struct tc_action_ops act_police_ops = {
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
 	.cleanup	=	tcf_act_police_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_act_police_locate,
 	.walk		=	tcf_act_police_walker
 };
-- 
1.7.10.4
