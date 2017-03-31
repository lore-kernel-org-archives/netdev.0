From: Joe Perches <joe@perches.com>
Subject: [PATCH] treewide: Correct diffrent[iate] and banlance typos
Date: Thu, 30 Mar 2017 20:44:16 -0700
Message-ID: <962aace119675e5fe87be2a88ddac1a5486f8e60.1490931810.git.joe@perches.com>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, Yishai Hadas <yishaih@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add these misspellings to scripts/spelling.txt too

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c       | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c           | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c          | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c         | 2 +-
 include/linux/mlx4/device.h                         | 2 +-
 scripts/spelling.txt                                | 3 +++
 8 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h b/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
index 354ec07eae87..23ae72468025 100644
--- a/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
+++ b/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
@@ -70,7 +70,7 @@
 * (3) both long and short but short preferred and long only when necesarry
 *
 * These modes must be selected compile time via compile switches.
-* Compile switch settings for the diffrent modes:
+* Compile switch settings for the different modes:
 * (1) DRXDAPFASI_LONG_ADDR_ALLOWED=0, DRXDAPFASI_SHORT_ADDR_ALLOWED=1
 * (2) DRXDAPFASI_LONG_ADDR_ALLOWED=1, DRXDAPFASI_SHORT_ADDR_ALLOWED=0
 * (3) DRXDAPFASI_LONG_ADDR_ALLOWED=1, DRXDAPFASI_SHORT_ADDR_ALLOWED=1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index cea6bdcde33f..8baf9d3eb4b1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -1591,7 +1591,7 @@ static int __bnx2x_vlan_mac_execute_step(struct bnx2x *bp,
 	if (rc != 0) {
 		__bnx2x_vlan_mac_h_pend(bp, o, *ramrod_flags);
 
-		/* Calling function should not diffrentiate between this case
+		/* Calling function should not differentiate between this case
 		 * and the case in which there is already a pending ramrod
 		 */
 		rc = 1;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index fca37e2c7f01..e70324f4fe84 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1207,7 +1207,7 @@ static void hns_set_irq_affinity(struct hns_nic_priv *priv)
 	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
 		return;
 
-	/*diffrent irq banlance for 16core and 32core*/
+	/* different irq balance for 16core and 32core */
 	if (h->q_num == num_possible_cpus()) {
 		for (i = 0; i < h->q_num * 2; i++) {
 			rd = &priv->ring_data[i];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 84310b60849b..c6b348f00e7b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -3057,7 +3057,7 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 
 	/* There's a possibility the igu_sb_cnt_iov doesn't properly reflect
 	 * the number of VF SBs [especially for first VF on engine, as we can't
-	 * diffrentiate between empty entries and its entries].
+	 * differentiate between empty entries and its entries].
 	 * Since we don't really support more SBs than VFs today, prevent any
 	 * such configuration by sanitizing the number of SBs to equal the
 	 * number of VFs.
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index d4edb993b1b0..b595f7dd4a58 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -951,7 +951,7 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 		if (rc)
 			goto err2;
 
-		/* First Dword used to diffrentiate between various sources */
+		/* First Dword used to differentiate between various sources */
 		data = cdev->firmware->data + sizeof(u32);
 
 		qed_dbg_pf_init(cdev);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 18fc6e62ca41..a69774b19712 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -625,7 +625,7 @@ int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
 	 *  - If !ARI, VFs would start on next device.
 	 *    so offset - (256 - pf_id) would provide the number.
 	 * Utilize the fact that (256 - pf_id) is achieved only by later
-	 * to diffrentiate between the two.
+	 * to differentiate between the two.
 	 */
 
 	if (p_hwfn->cdev->p_iov_info->offset < (256 - p_hwfn->abs_pf_id)) {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1beb1ec2fbdf..eb1a51a6617b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -108,7 +108,7 @@ enum {
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
 };
 
-/* Driver supports 3 diffrent device methods to manage traffic steering:
+/* Driver supports 3 different device methods to manage traffic steering:
  *	-device managed - High level API for ib and eth flow steering. FW is
  *			  managing flow steering tables.
  *	- B0 steering mode - Common low level API for ib and (if supported) eth.
diff --git a/scripts/spelling.txt b/scripts/spelling.txt
index 412f576ba4d7..e9cea4c5b6a1 100644
--- a/scripts/spelling.txt
+++ b/scripts/spelling.txt
@@ -174,6 +174,7 @@ bakup||backup
 baloon||balloon
 baloons||balloons
 bandwith||bandwidth
+banlance||balance
 batery||battery
 beacuse||because
 becasue||because
@@ -365,6 +366,8 @@ dictionnary||dictionary
 didnt||didn't
 diferent||different
 differrence||difference
+diffrent||different
+diffrentiate||differentiate
 difinition||definition
 diplay||display
 direectly||directly
-- 
2.10.0.rc2.1.g053435c
