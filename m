From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 232/235]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7053:6: sparse: symbol
 'bnx2x_init_searcher' was not declared. Should it be static?
Date: Thu, 8 Nov 2012 17:38:05 +0800
Message-ID: <20121108093805.GA1891@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3817 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab2KHJiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 04:38:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi Merav,

FYI, there are new sparse warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   f1e0b5b4f1eae56a3192688177f36e2bdf0e01ac
commit: 55c11941e382cb26010138ab824216f47af37606 [232/235] bnx2x: Support loading cnic resources at run-time

drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2465:55: sparse: Using plain integer as NULL pointer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2490:55: sparse: Using plain integer as NULL pointer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2506:39: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2506:39:    expected unsigned short [unsigned] [usertype] vif_list_index
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2506:39:    got restricted __le16 [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3013:30: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3013:30:    expected restricted __le32 [usertype] hi
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3013:30:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3014:30: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3014:30:    expected restricted __le32 [usertype] lo
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3014:30:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3102:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3102:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3102:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3102:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3105:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3105:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3105:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3105:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3105:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3110:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3110:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3110:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3110:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3110:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3115:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3115:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3115:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3115:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3115:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3120:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3120:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3120:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3120:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3123:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3123:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3123:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3123:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3126:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3126:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3126:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3126:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3129:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3129:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3129:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3129:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3132:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3132:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3132:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3132:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3135:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3135:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3135:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3135:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3135:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3140:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3140:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3140:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3140:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3140:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3145:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3145:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3145:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3145:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3145:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3150:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3150:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3150:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3150:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3153:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3153:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3153:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3153:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3156:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3156:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3156:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3156:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3159:17: sparse: invalid assignment: +=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3159:17:    left side has type unsigned int
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3159:17:    right side has type restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3159:17: sparse: restricted __le32 degrades to integer
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:4815:23: sparse: cast to restricted __le32
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5279:51: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5279:51:    expected restricted __le32 [addressable] [assigned] [usertype] hi
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5279:51:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5280:51: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5280:51:    expected restricted __le32 [addressable] [assigned] [usertype] lo
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5280:51:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5294:52: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5294:52:    expected restricted __le32 [addressable] [assigned] [usertype] hi
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5294:52:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5295:52: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5295:52:    expected restricted __le32 [addressable] [assigned] [usertype] lo
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5295:52:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5398:41: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5398:41:    expected restricted __le32 [addressable] [assigned] [usertype] lo
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5398:41:    got unsigned int [unsigned] [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5399:41: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5399:41:    expected restricted __le32 [addressable] [assigned] [usertype] hi
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:5399:41:    got unsigned int [unsigned] [usertype] <noident>
+ drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7053:6: sparse: symbol 'bnx2x_init_searcher' was not declared. Should it be static?
+ drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7083:5: sparse: symbol 'bnx2x_reset_nic_mode' was not declared. Should it be static?
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7970:5: sparse: symbol 'bnx2x_setup_tx_only' was not declared. Should it be static?
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:9013:5: sparse: symbol 'bnx2x_leader_reset' was not declared. Should it be static?
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10292:16: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10292:16:    expected unsigned short [unsigned] [usertype] mac_hi
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10292:16:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10293:16: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10293:16:    expected unsigned int [unsigned] [usertype] mac_lo
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10293:16:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:11688:21: sparse: cast to restricted __be16
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:11688:21: sparse: cast to restricted __be16
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:11688:21: sparse: cast to restricted __be16
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:11688:21: sparse: cast to restricted __be16

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--UlVJffcvxoiEqYs2
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="make-it-static-55c1194.diff"

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0546cf4..49dec05 100644
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
@@ -7050,7 +7050,7 @@ static void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
 }
 
 
-void bnx2x_init_searcher(struct bnx2x *bp)
+static void bnx2x_init_searcher(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
@@ -7080,7 +7080,7 @@ static inline int bnx2x_func_switch_update(struct bnx2x *bp, int suspend)
 	return rc;
 }
 
-int bnx2x_reset_nic_mode(struct bnx2x *bp)
+static int bnx2x_reset_nic_mode(struct bnx2x *bp)
 {
 	int rc, i, port = BP_PORT(bp);
 	int vlan_en = 0, mac_en[NUM_MACS];
@@ -7967,7 +7967,7 @@ static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 	}
 }
 
-int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+static int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			struct bnx2x_queue_state_params *q_params,
 			struct bnx2x_queue_setup_tx_only_params *tx_only_params,
 			int tx_index, bool leading)
@@ -9010,7 +9010,7 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 	return 0;
 }
 
-int bnx2x_leader_reset(struct bnx2x *bp)
+static int bnx2x_leader_reset(struct bnx2x *bp)
 {
 	int rc = 0;
 	bool global = bnx2x_reset_is_global(bp);

--UlVJffcvxoiEqYs2--
