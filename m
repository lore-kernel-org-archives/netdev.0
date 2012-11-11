From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch] bnx2x: Add static declaration to several
 functions
Date: Sun, 11 Nov 2012 15:56:08 +0200
Message-ID: <1352642168-22759-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	"Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1173 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab2KKKsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2012 05:48:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds static declaration to several functions in bnx2x. It eliminates
newly introduced sparse warnings reported by Fengguang Wu.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this patch to net-next.

Thanks,
Merav

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   20 ++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 +++++-----
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index cd00294..c98da25 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11934,8 +11934,8 @@ int bnx2x_phy_probe(struct link_params *params)
 	return 0;
 }

-void bnx2x_init_bmac_loopback(struct link_params *params,
-			      struct link_vars *vars)
+static void bnx2x_init_bmac_loopback(struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 		vars->link_up = 1;
@@ -11954,8 +11954,8 @@ void bnx2x_init_bmac_loopback(struct link_params *params,
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 }

-void bnx2x_init_emac_loopback(struct link_params *params,
-			      struct link_vars *vars)
+static void bnx2x_init_emac_loopback(struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 		vars->link_up = 1;
@@ -11973,8 +11973,8 @@ void bnx2x_init_emac_loopback(struct link_params *params,
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 }

-void bnx2x_init_xmac_loopback(struct link_params *params,
-			      struct link_vars *vars)
+static void bnx2x_init_xmac_loopback(struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	vars->link_up = 1;
@@ -11999,8 +11999,8 @@ void bnx2x_init_xmac_loopback(struct link_params *params,
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 }

-void bnx2x_init_umac_loopback(struct link_params *params,
-			      struct link_vars *vars)
+static void bnx2x_init_umac_loopback(struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	vars->link_up = 1;
@@ -12014,8 +12014,8 @@ void bnx2x_init_umac_loopback(struct link_params *params,
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 }

-void bnx2x_init_xgxs_loopback(struct link_params *params,
-			      struct link_vars *vars)
+static void bnx2x_init_xgxs_loopback(struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 		vars->link_up = 1;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 04b9f0a..3519fed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1482,7 +1482,7 @@ static void bnx2x_igu_int_disable(struct bnx2x *bp)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }

-void bnx2x_int_disable(struct bnx2x *bp)
+static void bnx2x_int_disable(struct bnx2x *bp)
 {
 	if (bp->common.int_block == INT_BLOCK_HC)
 		bnx2x_hc_int_disable(bp);
@@ -7051,7 +7051,7 @@ static void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
 }


-void bnx2x_init_searcher(struct bnx2x *bp)
+static void bnx2x_init_searcher(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
@@ -7081,7 +7081,7 @@ static inline int bnx2x_func_switch_update(struct bnx2x *bp, int suspend)
 	return rc;
 }

-int bnx2x_reset_nic_mode(struct bnx2x *bp)
+static int bnx2x_reset_nic_mode(struct bnx2x *bp)
 {
 	int rc, i, port = BP_PORT(bp);
 	int vlan_en = 0, mac_en[NUM_MACS];
@@ -7968,7 +7968,7 @@ static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 	}
 }

-int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+static int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			struct bnx2x_queue_state_params *q_params,
 			struct bnx2x_queue_setup_tx_only_params *tx_only_params,
 			int tx_index, bool leading)
@@ -9011,7 +9011,7 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 	return 0;
 }

-int bnx2x_leader_reset(struct bnx2x *bp)
+static int bnx2x_leader_reset(struct bnx2x *bp)
 {
 	int rc = 0;
 	bool global = bnx2x_reset_is_global(bp);
--
1.7.10
