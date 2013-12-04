From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 5/5] net_sched: Use default action walker methods
Date: Wed,  4 Dec 2013 09:26:56 -0500
Message-ID: <1386167216-30281-6-git-send-email-jhs@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:48505 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333Ab3LDO1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:43 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so27306539iej.28
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:42 -0800 (PST)
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_csum.c    |    1 -
 net/sched/act_gact.c    |    1 -
 net/sched/act_ipt.c     |    2 --
 net/sched/act_mirred.c  |    1 -
 net/sched/act_nat.c     |    1 -
 net/sched/act_pedit.c   |    1 -
 net/sched/act_simple.c  |    1 -
 net/sched/act_skbedit.c |    1 -
 8 files changed, 9 deletions(-)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 4225a93..5c5edf5 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -586,7 +586,6 @@ static struct tc_action_ops act_csum_ops = {
 	.dump		= tcf_csum_dump,
 	.cleanup	= tcf_csum_cleanup,
 	.init		= tcf_csum_init,
-	.walk		= tcf_generic_walker
 };
 
 MODULE_DESCRIPTION("Checksum updating actions");
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 15851da..5645a4d 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -207,7 +207,6 @@ static struct tc_action_ops act_gact_ops = {
 	.dump		=	tcf_gact_dump,
 	.cleanup	=	tcf_gact_cleanup,
 	.init		=	tcf_gact_init,
-	.walk		=	tcf_generic_walker
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 1d3e191..882a897 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -299,7 +299,6 @@ static struct tc_action_ops act_ipt_ops = {
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
 	.init		=	tcf_ipt_init,
-	.walk		=	tcf_generic_walker
 };
 
 static struct tc_action_ops act_xt_ops = {
@@ -312,7 +311,6 @@ static struct tc_action_ops act_xt_ops = {
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
 	.init		=	tcf_ipt_init,
-	.walk		=	tcf_generic_walker
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-13)");
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6cb16ec..2523781 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -272,7 +272,6 @@ static struct tc_action_ops act_mirred_ops = {
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_cleanup,
 	.init		=	tcf_mirred_init,
-	.walk		=	tcf_generic_walker
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002)");
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 30c13de..6a15ace 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -309,7 +309,6 @@ static struct tc_action_ops act_nat_ops = {
 	.dump		=	tcf_nat_dump,
 	.cleanup	=	tcf_nat_cleanup,
 	.init		=	tcf_nat_init,
-	.walk		=	tcf_generic_walker
 };
 
 MODULE_DESCRIPTION("Stateless NAT actions");
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index ab4fc56..03b6767 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -244,7 +244,6 @@ static struct tc_action_ops act_pedit_ops = {
 	.dump		=	tcf_pedit_dump,
 	.cleanup	=	tcf_pedit_cleanup,
 	.init		=	tcf_pedit_init,
-	.walk		=	tcf_generic_walker
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 7725eb4..31157d3 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -201,7 +201,6 @@ static struct tc_action_ops act_simp_ops = {
 	.dump		=	tcf_simp_dump,
 	.cleanup	=	tcf_simp_cleanup,
 	.init		=	tcf_simp_init,
-	.walk		=	tcf_generic_walker,
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2005)");
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index cb42211..35ea643 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -203,7 +203,6 @@ static struct tc_action_ops act_skbedit_ops = {
 	.dump		=	tcf_skbedit_dump,
 	.cleanup	=	tcf_skbedit_cleanup,
 	.init		=	tcf_skbedit_init,
-	.walk		=	tcf_generic_walker,
 };
 
 MODULE_AUTHOR("Alexander Duyck, <alexander.h.duyck@intel.com>");
-- 
1.7.10.4
