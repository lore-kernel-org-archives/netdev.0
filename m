From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e: remove VF device IDs from PF
Date: Tue, 16 Feb 2016 21:34:20 -0800
Message-ID: <1455687262-20453-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756431AbcBQFe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:28 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The PF doesn't need to know about the VF's device IDs, so remove them.

Change-ID: I62cf0e0fffa1ace586e58e00bc271b10ae440f05
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 8 --------
 drivers/net/ethernet/intel/i40e/i40e_devids.h | 4 ----
 2 files changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 3b03a31..9018f28 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -62,14 +62,6 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_10G_BASE_T_X722:
 			hw->mac.type = I40E_MAC_X722;
 			break;
-		case I40E_DEV_ID_X722_VF:
-		case I40E_DEV_ID_X722_VF_HV:
-			hw->mac.type = I40E_MAC_X722_VF;
-			break;
-		case I40E_DEV_ID_VF:
-		case I40E_DEV_ID_VF_HV:
-			hw->mac.type = I40E_MAC_VF;
-			break;
 		default:
 			hw->mac.type = I40E_MAC_GENERIC;
 			break;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_devids.h b/drivers/net/ethernet/intel/i40e/i40e_devids.h
index f7ce5c7..99257fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_devids.h
@@ -39,15 +39,11 @@
 #define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_20G_KR2_A		0x1588
 #define I40E_DEV_ID_10G_BASE_T4		0x1589
-#define I40E_DEV_ID_VF			0x154C
-#define I40E_DEV_ID_VF_HV		0x1571
 #define I40E_DEV_ID_KX_X722		0x37CE
 #define I40E_DEV_ID_QSFP_X722		0x37CF
 #define I40E_DEV_ID_SFP_X722		0x37D0
 #define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
 #define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
-#define I40E_DEV_ID_X722_VF		0x37CD
-#define I40E_DEV_ID_X722_VF_HV		0x37D9
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
 					 (d) == I40E_DEV_ID_QSFP_B  || \
-- 
2.5.0
