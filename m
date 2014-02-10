From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 9/9] bnx2x: utilize FW 7.8.19
Date: Mon, 10 Feb 2014 17:17:02 +0200
Message-ID: <1392045422-5437-10-git-send-email-yuvalmin@broadcom.com>
References: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Dmitry Kravkov <dmitry@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:31740 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaBJPRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 10:17:19 -0500
In-Reply-To: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

    This new firmware fixes following bugs:
     1. HW attention appears and traffic stops when iSCSI firmware tries to
        retransmit iSCSI login command when the iSCSI login is carrying data
        not aligned to 4-bytes.
     2. FCoE traffic fails to run when running in switch-independent multi-function
        mode and there's more than one interface supporting FCoE on a given port.
     3. While two ports are running FCoE with at least one of them has a function
        number (>1) on the same engine in a 4-port device a zeroed CQE is given,
        causing FCoE traffic to stop.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 391f29e..064824a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -26,8 +26,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.78.17-0"
-#define DRV_MODULE_RELDATE      "2013/04/11"
+#define DRV_MODULE_VERSION      "1.78.19-0"
+#define DRV_MODULE_RELDATE      "2014/02/10"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index cf1df8b..46e2f18 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2848,7 +2848,7 @@ struct afex_stats {
 
 #define BCM_5710_FW_MAJOR_VERSION			7
 #define BCM_5710_FW_MINOR_VERSION			8
-#define BCM_5710_FW_REVISION_VERSION		17
+#define BCM_5710_FW_REVISION_VERSION		19
 #define BCM_5710_FW_ENGINEERING_VERSION		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
-- 
1.8.5.3
