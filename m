From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 09/12] be2net: remove unnecessary blank lines after an open brace
Date: Fri, 19 Sep 2014 15:46:59 +0530
Message-ID: <1411121822-25842-10-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665AbaISKOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:33 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch fixes checkpatch warnings about blank lines after an open brace '{'.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 --
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bc47d17..9ec09a8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -209,7 +209,6 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 
 	if (base_status != MCC_STATUS_SUCCESS &&
 	    !be_skip_err_log(opcode, base_status, addl_status)) {
-
 		if (base_status == MCC_STATUS_UNAUTHORIZED_REQUEST) {
 			dev_warn(&adapter->pdev->dev,
 				 "VF is not privileged to issue opcode %d-%d\n",
@@ -1522,7 +1521,6 @@ err:
 int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			       struct be_dma_mem *nonemb_cmd)
 {
-
 	struct be_mcc_wrb *wrb;
 	struct lancer_cmd_req_pport_stats *req;
 	int status = 0;
@@ -3038,7 +3036,6 @@ out:
 int be_cmd_get_active_mac(struct be_adapter *adapter, u32 curr_pmac_id,
 			  u8 *mac, u32 if_handle, bool active, u32 domain)
 {
-
 	if (!active)
 		be_cmd_get_mac_from_list(adapter, mac, &active, &curr_pmac_id,
 					 if_handle, domain);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 31b5fdc..7e80527 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -493,7 +493,6 @@ static void populate_be_v2_stats(struct be_adapter *adapter)
 
 static void populate_lancer_stats(struct be_adapter *adapter)
 {
-
 	struct be_drv_stats *drvs = &adapter->drv_stats;
 	struct lancer_pport_stats *pport_stats = pport_stats_from_cmd(adapter);
 
@@ -4741,7 +4740,6 @@ static void be_func_recovery_task(struct work_struct *work)
 	be_detect_error(adapter);
 
 	if (adapter->hw_error && lancer_chip(adapter)) {
-
 		rtnl_lock();
 		netif_device_detach(adapter->netdev);
 		rtnl_unlock();
-- 
1.7.1
