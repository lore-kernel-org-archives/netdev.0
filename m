From: Jonathan Toppins <jtoppins@redhat.com>
Subject: [PATCH net-next 2/2] bnxt_en: tc: only the function prototypes need to be wrapped in #ifdef
Date: Fri,  6 Oct 2017 15:48:31 -0400
Message-ID: <a58d04f653e79b12c86eaa67f768f4ff64b2a975.1507319311.git.jtoppins@redhat.com>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org (open list)
To: michael.chan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
In-Reply-To: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason to wrap the data structures inside the ifdef.

Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
index 6c4c1ed279ef..6e771e9eed51 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
@@ -10,8 +10,6 @@
 #ifndef BNXT_TC_H
 #define BNXT_TC_H
 
-#ifdef CONFIG_BNXT_FLOWER_OFFLOAD
-
 /* Structs used for storing the filter/actions of the TC cmd.
  */
 struct bnxt_tc_l2_key {
@@ -133,6 +131,8 @@ struct bnxt_tc_flow_node {
 	struct rcu_head			rcu;
 };
 
+#if IS_ENABLED(CONFIG_BNXT_FLOWER_OFFLOAD)
+
 int bnxt_tc_setup_flower(struct bnxt *bp, u16 src_fid,
 			 struct tc_cls_flower_offload *cls_flower);
 int bnxt_init_tc(struct bnxt *bp);
-- 
2.13.6
