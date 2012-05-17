From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] e1000e: fix typo in definition of E1000_CTRL_EXT_FORCE_SMBUS
Date: Thu, 17 May 2012 05:31:49 -0700
Message-ID: <1337257912-8487-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56414 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760586Ab2EQMbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 08:31:55 -0400
In-Reply-To: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This define is needed by i217.

Reported-by: Bjorn Mork <bjorn@mork.no>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 11c4666..351a409 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -76,7 +76,7 @@
 /* Extended Device Control */
 #define E1000_CTRL_EXT_LPCD  0x00000004     /* LCD Power Cycle Done */
 #define E1000_CTRL_EXT_SDP3_DATA 0x00000080 /* Value of SW Definable Pin 3 */
-#define E1000_CTRL_EXT_FORCE_SMBUS 0x00000004 /* Force SMBus mode*/
+#define E1000_CTRL_EXT_FORCE_SMBUS 0x00000800 /* Force SMBus mode */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_SPD_BYPS  0x00008000 /* Speed Select Bypass */
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
-- 
1.7.7.6
