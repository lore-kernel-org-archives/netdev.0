From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Remove id's that will not be productized for Linux.
Date: Sat, 20 Apr 2013 02:49:12 -0700
Message-ID: <1366451353-24714-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1830 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab3DTJtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:24 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch removes id defines from the hardware files that will not be
productized for Linux.  These id's were not implemented for support in the
base driver itself, they were just available defines.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 2 --
 drivers/net/ethernet/intel/igb/e1000_hw.h    | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index d3d72e0..ff6a17c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -443,8 +443,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		mac->type = e1000_i350;
 		break;
 	case E1000_DEV_ID_I210_COPPER:
-	case E1000_DEV_ID_I210_COPPER_OEM1:
-	case E1000_DEV_ID_I210_COPPER_IT:
 	case E1000_DEV_ID_I210_FIBER:
 	case E1000_DEV_ID_I210_SERDES:
 	case E1000_DEV_ID_I210_SGMII:
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index f1dbab9..488abb2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -64,8 +64,6 @@ struct e1000_hw;
 #define E1000_DEV_ID_I350_SERDES		0x1523
 #define E1000_DEV_ID_I350_SGMII			0x1524
 #define E1000_DEV_ID_I210_COPPER		0x1533
-#define E1000_DEV_ID_I210_COPPER_OEM1		0x1534
-#define E1000_DEV_ID_I210_COPPER_IT		0x1535
 #define E1000_DEV_ID_I210_FIBER			0x1536
 #define E1000_DEV_ID_I210_SERDES		0x1537
 #define E1000_DEV_ID_I210_SGMII			0x1538
-- 
1.7.11.7
