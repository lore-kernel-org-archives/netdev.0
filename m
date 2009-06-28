From: Joe Perches <joe@perches.com>
Subject: [PATCH 31/62] drivers/net/skfp: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:36 -0700
Message-ID: <fa7a1ba66b2408d52eb324acc6cd406b156bb8c0.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1129 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbZF1Q1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:46 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skfp/pcmplc.c |    2 +-
 drivers/net/skfp/pmf.c    |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/skfp/pcmplc.c b/drivers/net/skfp/pcmplc.c
index f1df2ec..e6b33ee 100644
--- a/drivers/net/skfp/pcmplc.c
+++ b/drivers/net/skfp/pcmplc.c
@@ -960,7 +960,7 @@ static void pcm_fsm(struct s_smc *smc, struct s_phy *phy, int cmd)
 			/*PC88b*/
 			if (!phy->cf_join) {
 				phy->cf_join = TRUE ;
-				queue_event(smc,EVENT_CFM,CF_JOIN+np) ; ;
+				queue_event(smc,EVENT_CFM,CF_JOIN+np) ;
 			}
 			if (cmd == PC_JOIN)
 				GO_STATE(PC8_ACTIVE) ;
diff --git a/drivers/net/skfp/pmf.c b/drivers/net/skfp/pmf.c
index 79e665e..a320fdb 100644
--- a/drivers/net/skfp/pmf.c
+++ b/drivers/net/skfp/pmf.c
@@ -807,9 +807,9 @@ void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
 				mib_p->fddiPORTLerFlag ;
 			sp->p4050_pad = 0 ;
 			sp->p4050_cutoff =
-				mib_p->fddiPORTLer_Cutoff ; ;
+				mib_p->fddiPORTLer_Cutoff ;
 			sp->p4050_alarm =
-				mib_p->fddiPORTLer_Alarm ; ;
+				mib_p->fddiPORTLer_Alarm ;
 			sp->p4050_estimate =
 				mib_p->fddiPORTLer_Estimate ;
 			sp->p4050_reject_ct =
@@ -829,7 +829,7 @@ void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
 			sp->p4051_porttype =
 				mib_p->fddiPORTMy_Type ;
 			sp->p4051_connectstate =
-				mib_p->fddiPORTConnectState ; ;
+				mib_p->fddiPORTConnectState ;
 			sp->p4051_pc_neighbor =
 				mib_p->fddiPORTNeighborType ;
 			sp->p4051_pc_withhold =
@@ -853,7 +853,7 @@ void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
 			struct smt_p_4053	*sp ;
 			sp = (struct smt_p_4053 *) to ;
 			sp->p4053_multiple =
-				mib_p->fddiPORTMultiple_P ; ;
+				mib_p->fddiPORTMultiple_P ;
 			sp->p4053_availablepaths =
 				mib_p->fddiPORTAvailablePaths ;
 			sp->p4053_currentpath =
-- 
1.6.3.1.10.g659a0.dirty

