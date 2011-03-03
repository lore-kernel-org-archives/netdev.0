From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/24] ixgbe: cleanup wake on LAN defines
Date: Thu,  3 Mar 2011 05:03:30 -0800
Message-ID: <1299157429-15878-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24647 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758112Ab1CCNEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:20 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change just cleans up a few defines in ixgbe_type.h related to wake on LAN.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_type.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index ab65d13..18780d0 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -91,7 +91,7 @@
 
 /* General Receive Control */
 #define IXGBE_GRC_MNG  0x00000001 /* Manageability Enable */
-#define IXGBE_GRC_APME 0x00000002 /* Advanced Power Management Enable */
+#define IXGBE_GRC_APME 0x00000002 /* APM enabled in EEPROM */
 
 #define IXGBE_VPDDIAG0  0x10204
 #define IXGBE_VPDDIAG1  0x10208
@@ -342,7 +342,7 @@
 /* Wake Up Control */
 #define IXGBE_WUC_PME_EN     0x00000002 /* PME Enable */
 #define IXGBE_WUC_PME_STATUS 0x00000004 /* PME Status */
-#define IXGBE_WUC_ADVD3WUC   0x00000010 /* D3Cold wake up cap. enable*/
+#define IXGBE_WUC_WKEN       0x00000010 /* Enable PE_WAKE_N pin assertion  */
 
 /* Wake Up Filter Control */
 #define IXGBE_WUFC_LNKC 0x00000001 /* Link Status Change Wakeup Enable */
-- 
1.7.4

