From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] i40e: Remove device ID 0x37D4
Date: Fri, 22 Jul 2016 00:36:32 -0700
Message-ID: <1469172999-8969-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:60535 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbcGVHgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:48 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

This device ID is not needed, so take it out.

Change-ID: I148d29f68a1f58b03980ecd83047a1b440f4f74d
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 1 -
 drivers/net/ethernet/intel/i40e/i40e_devids.h   | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_devids.h | 1 -
 5 files changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index bb63df8..2154a34 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -61,7 +61,6 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_1G_BASE_T_X722:
 		case I40E_DEV_ID_10G_BASE_T_X722:
 		case I40E_DEV_ID_SFP_I_X722:
-		case I40E_DEV_ID_QSFP_I_X722:
 			hw->mac.type = I40E_MAC_X722;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_devids.h b/drivers/net/ethernet/intel/i40e/i40e_devids.h
index d701861..dd4457d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_devids.h
@@ -45,7 +45,6 @@
 #define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
 #define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
 #define I40E_DEV_ID_SFP_I_X722		0x37D3
-#define I40E_DEV_ID_QSFP_I_X722		0x37D4
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
 					 (d) == I40E_DEV_ID_QSFP_B  || \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2b11405..28206da 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -86,7 +86,6 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_1G_BASE_T_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_I_X722), 0},
-	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_I_X722), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2_A), 0},
 	/* required last entry */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 8f64204..4db0c03 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -59,7 +59,6 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_1G_BASE_T_X722:
 		case I40E_DEV_ID_10G_BASE_T_X722:
 		case I40E_DEV_ID_SFP_I_X722:
-		case I40E_DEV_ID_QSFP_I_X722:
 			hw->mac.type = I40E_MAC_X722;
 			break;
 		case I40E_DEV_ID_X722_VF:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_devids.h b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
index d34972b..7023570 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
@@ -45,7 +45,6 @@
 #define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
 #define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
 #define I40E_DEV_ID_SFP_I_X722		0x37D3
-#define I40E_DEV_ID_QSFP_I_X722		0x37D4
 #define I40E_DEV_ID_X722_VF		0x37CD
 #define I40E_DEV_ID_X722_VF_HV		0x37D9
 
-- 
2.5.5
