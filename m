From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Fix the ECC-related bit position definitions
Date: Wed, 22 Mar 2017 17:25:27 -0500
Message-ID: <20170322222526.10361.35455.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0052.outbound.protection.outlook.com ([104.47.42.52]:16228
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752005AbdCVWZc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 18:25:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ECC bit positions that describe whether the ECC interrupt is for
Tx, Rx or descriptor memory and whether the it is a single correctable
or double detected error were defined in incorrectly (reversed order).
Fix the bit position definitions for these settings so that the proper
ECC handling is performed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---

Please queue this patch up for 4.10-stable.

 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 86f1626..127adbe 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -984,29 +984,29 @@
 #define XP_ECC_CNT1_DESC_DED_WIDTH		8
 #define XP_ECC_CNT1_DESC_SEC_INDEX		0
 #define XP_ECC_CNT1_DESC_SEC_WIDTH		8
-#define XP_ECC_IER_DESC_DED_INDEX		0
+#define XP_ECC_IER_DESC_DED_INDEX		5
 #define XP_ECC_IER_DESC_DED_WIDTH		1
-#define XP_ECC_IER_DESC_SEC_INDEX		1
+#define XP_ECC_IER_DESC_SEC_INDEX		4
 #define XP_ECC_IER_DESC_SEC_WIDTH		1
-#define XP_ECC_IER_RX_DED_INDEX			2
+#define XP_ECC_IER_RX_DED_INDEX			3
 #define XP_ECC_IER_RX_DED_WIDTH			1
-#define XP_ECC_IER_RX_SEC_INDEX			3
+#define XP_ECC_IER_RX_SEC_INDEX			2
 #define XP_ECC_IER_RX_SEC_WIDTH			1
-#define XP_ECC_IER_TX_DED_INDEX			4
+#define XP_ECC_IER_TX_DED_INDEX			1
 #define XP_ECC_IER_TX_DED_WIDTH			1
-#define XP_ECC_IER_TX_SEC_INDEX			5
+#define XP_ECC_IER_TX_SEC_INDEX			0
 #define XP_ECC_IER_TX_SEC_WIDTH			1
-#define XP_ECC_ISR_DESC_DED_INDEX		0
+#define XP_ECC_ISR_DESC_DED_INDEX		5
 #define XP_ECC_ISR_DESC_DED_WIDTH		1
-#define XP_ECC_ISR_DESC_SEC_INDEX		1
+#define XP_ECC_ISR_DESC_SEC_INDEX		4
 #define XP_ECC_ISR_DESC_SEC_WIDTH		1
-#define XP_ECC_ISR_RX_DED_INDEX			2
+#define XP_ECC_ISR_RX_DED_INDEX			3
 #define XP_ECC_ISR_RX_DED_WIDTH			1
-#define XP_ECC_ISR_RX_SEC_INDEX			3
+#define XP_ECC_ISR_RX_SEC_INDEX			2
 #define XP_ECC_ISR_RX_SEC_WIDTH			1
-#define XP_ECC_ISR_TX_DED_INDEX			4
+#define XP_ECC_ISR_TX_DED_INDEX			1
 #define XP_ECC_ISR_TX_DED_WIDTH			1
-#define XP_ECC_ISR_TX_SEC_INDEX			5
+#define XP_ECC_ISR_TX_SEC_INDEX			0
 #define XP_ECC_ISR_TX_SEC_WIDTH			1
 #define XP_I2C_MUTEX_BUSY_INDEX			31
 #define XP_I2C_MUTEX_BUSY_WIDTH			1
