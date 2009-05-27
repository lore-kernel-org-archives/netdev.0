From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] ixgbe: Remove device ID 0x10d8
Date: Tue, 26 May 2009 17:55:02 -0700
Message-ID: <20090527005502.28535.93314.stgit@localhost.localdomain>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:57102
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752491AbZE0AzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 20:55:16 -0400
In-Reply-To: <20090527005403.28535.8727.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Device ID 0x10d8 is the default silicon device ID for 82599.  However, the
device will not be functional without an EEPROM, so we want to prevent the
driver from loading on the device.  Otherwise, the driver will load, but no
PHY setup or PCIe setup will occur, causing the device to be unusable.  To
prevent users from encountering this, just remove the device ID.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    1 -
 drivers/net/ixgbe/ixgbe_type.h  |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index fef7397..5d27830 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -357,7 +357,6 @@ enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	}
 
 	switch (hw->device_id) {
-	case IXGBE_DEV_ID_82599:
 	case IXGBE_DEV_ID_82599_KX4:
 	case IXGBE_DEV_ID_82599_XAUI_LOM:
 		/* Default device ID is mezzanine card KX/KX4 */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 00c23be..0c8dee9 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -46,7 +46,6 @@
 #define IXGBE_DEV_ID_82598_DA_DUAL_PORT  0x10F1
 #define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
-#define IXGBE_DEV_ID_82599               0x10D8
 #define IXGBE_DEV_ID_82599_KX4           0x10F7
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC

