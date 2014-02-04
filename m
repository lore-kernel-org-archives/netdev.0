From: James M Leddy <james.leddy@redhat.com>
Subject: [PATCH net-next] bnx2[x]: Make module parameters readable
Date: Tue,  4 Feb 2014 15:10:59 -0500
Message-ID: <1391544659-5711-1-git-send-email-james.leddy@redhat.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088AbaBDULI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Feb 2014 15:11:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Occasionally users want to know what parameters their Broadcom drivers
are running with. For example, a user may want to know if MSI is
disabled.

This patch has been compile tested.

Signed-off-by: James M Leddy <james.leddy@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c             |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9d2deda..cda25ac 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -85,7 +85,7 @@ MODULE_FIRMWARE(FW_RV2P_FILE_09_Ax);
 
 static int disable_msi = 0;
 
-module_param(disable_msi, int, 0);
+module_param(disable_msi, int, S_IRUGO);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
 typedef enum {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e118a3e..639e287 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -95,29 +95,29 @@ MODULE_FIRMWARE(FW_FILE_NAME_E1H);
 MODULE_FIRMWARE(FW_FILE_NAME_E2);
 
 int bnx2x_num_queues;
-module_param_named(num_queues, bnx2x_num_queues, int, 0);
+module_param_named(num_queues, bnx2x_num_queues, int, S_IRUGO);
 MODULE_PARM_DESC(num_queues,
 		 " Set number of queues (default is as a number of CPUs)");
 
 static int disable_tpa;
-module_param(disable_tpa, int, 0);
+module_param(disable_tpa, int, S_IRUGO);
 MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
 static int int_mode;
-module_param(int_mode, int, 0);
+module_param(int_mode, int, S_IRUGO);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode other than MSI-X "
 				"(1 INT#x; 2 MSI)");
 
 static int dropless_fc;
-module_param(dropless_fc, int, 0);
+module_param(dropless_fc, int, S_IRUGO);
 MODULE_PARM_DESC(dropless_fc, " Pause on exhausted host ring");
 
 static int mrrs = -1;
-module_param(mrrs, int, 0);
+module_param(mrrs, int, S_IRUGO);
 MODULE_PARM_DESC(mrrs, " Force Max Read Req Size (0..3) (for debug)");
 
 static int debug;
-module_param(debug, int, 0);
+module_param(debug, int, S_IRUGO);
 MODULE_PARM_DESC(debug, " Default debug msglevel");
 
 struct workqueue_struct *bnx2x_wq;
-- 
1.7.1
