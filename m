From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  6/9] ixgbe: Cleanup the use of tabs and spaces
Date: Tue,  1 Oct 2013 04:33:53 -0700
Message-ID: <1380627236-3190-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47745 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845Ab3JALeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:02 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleans up the whitespace issues noticed during code review where
a mix of tabs and spaces were used for indentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h  | 40 +++++++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 12 ++++----
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index 24af12e..aae900a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -57,28 +57,28 @@
 #define IXGBE_SFF_QSFP_DEVICE_TECH	0x93
 
 /* Bitmasks */
-#define IXGBE_SFF_DA_PASSIVE_CABLE           0x4
-#define IXGBE_SFF_DA_ACTIVE_CABLE            0x8
-#define IXGBE_SFF_DA_SPEC_ACTIVE_LIMITING    0x4
-#define IXGBE_SFF_1GBASESX_CAPABLE           0x1
-#define IXGBE_SFF_1GBASELX_CAPABLE           0x2
-#define IXGBE_SFF_1GBASET_CAPABLE            0x8
-#define IXGBE_SFF_10GBASESR_CAPABLE          0x10
-#define IXGBE_SFF_10GBASELR_CAPABLE          0x20
-#define IXGBE_SFF_SOFT_RS_SELECT_MASK	0x8
-#define IXGBE_SFF_SOFT_RS_SELECT_10G	0x8
-#define IXGBE_SFF_SOFT_RS_SELECT_1G	0x0
-#define IXGBE_SFF_ADDRESSING_MODE	     0x4
-#define IXGBE_SFF_QSFP_DA_ACTIVE_CABLE       0x1
-#define IXGBE_SFF_QSFP_DA_PASSIVE_CABLE      0x8
+#define IXGBE_SFF_DA_PASSIVE_CABLE		0x4
+#define IXGBE_SFF_DA_ACTIVE_CABLE		0x8
+#define IXGBE_SFF_DA_SPEC_ACTIVE_LIMITING	0x4
+#define IXGBE_SFF_1GBASESX_CAPABLE		0x1
+#define IXGBE_SFF_1GBASELX_CAPABLE		0x2
+#define IXGBE_SFF_1GBASET_CAPABLE		0x8
+#define IXGBE_SFF_10GBASESR_CAPABLE		0x10
+#define IXGBE_SFF_10GBASELR_CAPABLE		0x20
+#define IXGBE_SFF_SOFT_RS_SELECT_MASK		0x8
+#define IXGBE_SFF_SOFT_RS_SELECT_10G		0x8
+#define IXGBE_SFF_SOFT_RS_SELECT_1G		0x0
+#define IXGBE_SFF_ADDRESSING_MODE		0x4
+#define IXGBE_SFF_QSFP_DA_ACTIVE_CABLE		0x1
+#define IXGBE_SFF_QSFP_DA_PASSIVE_CABLE		0x8
 #define IXGBE_SFF_QSFP_CONNECTOR_NOT_SEPARABLE	0x23
 #define IXGBE_SFF_QSFP_TRANSMITER_850NM_VCSEL	0x0
-#define IXGBE_I2C_EEPROM_READ_MASK           0x100
-#define IXGBE_I2C_EEPROM_STATUS_MASK         0x3
-#define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION 0x0
-#define IXGBE_I2C_EEPROM_STATUS_PASS         0x1
-#define IXGBE_I2C_EEPROM_STATUS_FAIL         0x2
-#define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS  0x3
+#define IXGBE_I2C_EEPROM_READ_MASK		0x100
+#define IXGBE_I2C_EEPROM_STATUS_MASK		0x3
+#define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION	0x0
+#define IXGBE_I2C_EEPROM_STATUS_PASS		0x1
+#define IXGBE_I2C_EEPROM_STATUS_FAIL		0x2
+#define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS	0x3
 
 /* Flow control defines */
 #define IXGBE_TAF_SYM_PAUSE                  0x400
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 389324f..24b80a6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -32,12 +32,12 @@
 #include "ixgbe.h"
 #include "ixgbe_phy.h"
 
-#define IXGBE_X540_MAX_TX_QUEUES 128
-#define IXGBE_X540_MAX_RX_QUEUES 128
-#define IXGBE_X540_RAR_ENTRIES   128
-#define IXGBE_X540_MC_TBL_SIZE   128
-#define IXGBE_X540_VFT_TBL_SIZE  128
-#define IXGBE_X540_RX_PB_SIZE	 384
+#define IXGBE_X540_MAX_TX_QUEUES	128
+#define IXGBE_X540_MAX_RX_QUEUES	128
+#define IXGBE_X540_RAR_ENTRIES		128
+#define IXGBE_X540_MC_TBL_SIZE		128
+#define IXGBE_X540_VFT_TBL_SIZE		128
+#define IXGBE_X540_RX_PB_SIZE		384
 
 static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw);
 static s32 ixgbe_poll_flash_update_done_X540(struct ixgbe_hw *hw);
-- 
1.8.3.1
