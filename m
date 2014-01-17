From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 9/9] i40e: Fix device ID define names to align to standard
Date: Fri, 17 Jan 2014 15:36:39 -0800
Message-ID: <1390001799-19425-10-git-send-email-aaron.f.brown@intel.com>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41837 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897AbaAQXgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:36:46 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Rework the device ID #defines to follow the _DEV_ID convention
already established in the other Intel drivers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 24 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 22 +++++++--------
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 32 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  4 +--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 24 ++++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 32 +++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  2 +-
 7 files changed, 70 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 3f9f69b..e7f38b5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -42,20 +42,20 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 
 	if (hw->vendor_id == PCI_VENDOR_ID_INTEL) {
 		switch (hw->device_id) {
-		case I40E_SFP_XL710_DEVICE_ID:
-		case I40E_SFP_X710_DEVICE_ID:
-		case I40E_QEMU_DEVICE_ID:
-		case I40E_KX_A_DEVICE_ID:
-		case I40E_KX_B_DEVICE_ID:
-		case I40E_KX_C_DEVICE_ID:
-		case I40E_KX_D_DEVICE_ID:
-		case I40E_QSFP_A_DEVICE_ID:
-		case I40E_QSFP_B_DEVICE_ID:
-		case I40E_QSFP_C_DEVICE_ID:
+		case I40E_DEV_ID_SFP_XL710:
+		case I40E_DEV_ID_SFP_X710:
+		case I40E_DEV_ID_QEMU:
+		case I40E_DEV_ID_KX_A:
+		case I40E_DEV_ID_KX_B:
+		case I40E_DEV_ID_KX_C:
+		case I40E_DEV_ID_KX_D:
+		case I40E_DEV_ID_QSFP_A:
+		case I40E_DEV_ID_QSFP_B:
+		case I40E_DEV_ID_QSFP_C:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
-		case I40E_VF_DEVICE_ID:
-		case I40E_VF_HV_DEVICE_ID:
+		case I40E_DEV_ID_VF:
+		case I40E_DEV_ID_VF_HV:
 			hw->mac.type = I40E_MAC_VF;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3a9ede6..a4b9408 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -65,16 +65,16 @@ static int i40e_veb_get_bw_info(struct i40e_veb *veb);
  *   Class, Class Mask, private data (not used) }
  */
 static DEFINE_PCI_DEVICE_TABLE(i40e_pci_tbl) = {
-	{PCI_VDEVICE(INTEL, I40E_SFP_XL710_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_SFP_X710_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_QEMU_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_KX_A_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_KX_B_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_KX_C_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_KX_D_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_QSFP_A_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_QSFP_B_DEVICE_ID), 0},
-	{PCI_VDEVICE(INTEL, I40E_QSFP_C_DEVICE_ID), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_XL710), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_X710), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QEMU), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_A), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_B), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_C), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_D), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_A), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_B), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
 	/* required last entry */
 	{0, }
 };
@@ -469,7 +469,7 @@ static void i40e_stat_update48(struct i40e_hw *hw, u32 hireg, u32 loreg,
 {
 	u64 new_data;
 
-	if (hw->device_id == I40E_QEMU_DEVICE_ID) {
+	if (hw->device_id == I40E_DEV_ID_QEMU) {
 		new_data = rd32(hw, loreg);
 		new_data |= ((u64)(rd32(hw, hireg) & 0xFFFF)) << 32;
 	} else {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index d33ede9..181a825 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -35,22 +35,22 @@
 #include "i40e_lan_hmc.h"
 
 /* Device IDs */
-#define I40E_SFP_XL710_DEVICE_ID	0x1572
-#define I40E_SFP_X710_DEVICE_ID		0x1573
-#define I40E_QEMU_DEVICE_ID		0x1574
-#define I40E_KX_A_DEVICE_ID		0x157F
-#define I40E_KX_B_DEVICE_ID		0x1580
-#define I40E_KX_C_DEVICE_ID		0x1581
-#define I40E_KX_D_DEVICE_ID		0x1582
-#define I40E_QSFP_A_DEVICE_ID		0x1583
-#define I40E_QSFP_B_DEVICE_ID		0x1584
-#define I40E_QSFP_C_DEVICE_ID		0x1585
-#define I40E_VF_DEVICE_ID		0x154C
-#define I40E_VF_HV_DEVICE_ID		0x1571
-
-#define i40e_is_40G_device(d)		((d) == I40E_QSFP_A_DEVICE_ID  || \
-					 (d) == I40E_QSFP_B_DEVICE_ID  || \
-					 (d) == I40E_QSFP_C_DEVICE_ID)
+#define I40E_DEV_ID_SFP_XL710		0x1572
+#define I40E_DEV_ID_SFP_X710		0x1573
+#define I40E_DEV_ID_QEMU		0x1574
+#define I40E_DEV_ID_KX_A		0x157F
+#define I40E_DEV_ID_KX_B		0x1580
+#define I40E_DEV_ID_KX_C		0x1581
+#define I40E_DEV_ID_KX_D		0x1582
+#define I40E_DEV_ID_QSFP_A		0x1583
+#define I40E_DEV_ID_QSFP_B		0x1584
+#define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_VF			0x154C
+#define I40E_DEV_ID_VF_HV		0x1571
+
+#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
+					 (d) == I40E_DEV_ID_QSFP_B  || \
+					 (d) == I40E_DEV_ID_QSFP_C)
 
 #define I40E_MAX_VSI_QP			16
 #define I40E_MAX_VF_VSI			3
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 44bb359..b9d1c1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -700,7 +700,7 @@ static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
 	struct pci_dev *vfdev;
 
 	/* loop through all the VFs to see if we own any that are assigned */
-	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_VF_DEVICE_ID , NULL);
+	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_DEV_ID_VF , NULL);
 	while (vfdev) {
 		/* if we don't own it we don't care */
 		if (vfdev->is_virtfn && pci_physfn(vfdev) == pdev) {
@@ -710,7 +710,7 @@ static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
 		}
 
 		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
-				       I40E_VF_DEVICE_ID,
+				       I40E_DEV_ID_VF,
 				       vfdev);
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 44b90b3..7b13953 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -39,20 +39,20 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 
 	if (hw->vendor_id == PCI_VENDOR_ID_INTEL) {
 		switch (hw->device_id) {
-		case I40E_SFP_XL710_DEVICE_ID:
-		case I40E_SFP_X710_DEVICE_ID:
-		case I40E_QEMU_DEVICE_ID:
-		case I40E_KX_A_DEVICE_ID:
-		case I40E_KX_B_DEVICE_ID:
-		case I40E_KX_C_DEVICE_ID:
-		case I40E_KX_D_DEVICE_ID:
-		case I40E_QSFP_A_DEVICE_ID:
-		case I40E_QSFP_B_DEVICE_ID:
-		case I40E_QSFP_C_DEVICE_ID:
+		case I40E_DEV_ID_SFP_XL710:
+		case I40E_DEV_ID_SFP_X710:
+		case I40E_DEV_ID_QEMU:
+		case I40E_DEV_ID_KX_A:
+		case I40E_DEV_ID_KX_B:
+		case I40E_DEV_ID_KX_C:
+		case I40E_DEV_ID_KX_D:
+		case I40E_DEV_ID_QSFP_A:
+		case I40E_DEV_ID_QSFP_B:
+		case I40E_DEV_ID_QSFP_C:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
-		case I40E_VF_DEVICE_ID:
-		case I40E_VF_HV_DEVICE_ID:
+		case I40E_DEV_ID_VF:
+		case I40E_DEV_ID_VF_HV:
 			hw->mac.type = I40E_MAC_VF;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index beb3fa7..3bffac0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -32,22 +32,22 @@
 #include "i40e_lan_hmc.h"
 
 /* Device IDs */
-#define I40E_SFP_XL710_DEVICE_ID	0x1572
-#define I40E_SFP_X710_DEVICE_ID		0x1573
-#define I40E_QEMU_DEVICE_ID		0x1574
-#define I40E_KX_A_DEVICE_ID		0x157F
-#define I40E_KX_B_DEVICE_ID		0x1580
-#define I40E_KX_C_DEVICE_ID		0x1581
-#define I40E_KX_D_DEVICE_ID		0x1582
-#define I40E_QSFP_A_DEVICE_ID		0x1583
-#define I40E_QSFP_B_DEVICE_ID		0x1584
-#define I40E_QSFP_C_DEVICE_ID		0x1585
-#define I40E_VF_DEVICE_ID		0x154C
-#define I40E_VF_HV_DEVICE_ID		0x1571
-
-#define i40e_is_40G_device(d)		((d) == I40E_QSFP_A_DEVICE_ID  || \
-					 (d) == I40E_QSFP_B_DEVICE_ID  || \
-					 (d) == I40E_QSFP_C_DEVICE_ID)
+#define I40E_DEV_ID_SFP_XL710	0x1572
+#define I40E_DEV_ID_SFP_X710		0x1573
+#define I40E_DEV_ID_QEMU		0x1574
+#define I40E_DEV_ID_KX_A		0x157F
+#define I40E_DEV_ID_KX_B		0x1580
+#define I40E_DEV_ID_KX_C		0x1581
+#define I40E_DEV_ID_KX_D		0x1582
+#define I40E_DEV_ID_QSFP_A		0x1583
+#define I40E_DEV_ID_QSFP_B		0x1584
+#define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_VF		0x154C
+#define I40E_DEV_ID_VF_HV		0x1571
+
+#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
+					 (d) == I40E_DEV_ID_QSFP_B  || \
+					 (d) == I40E_DEV_ID_QSFP_C)
 
 #define I40E_MAX_VSI_QP			16
 #define I40E_MAX_VF_VSI			3
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 06bf8253..f5caf44 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -45,7 +45,7 @@ static const char i40evf_copyright[] =
  *   Class, Class Mask, private data (not used) }
  */
 static DEFINE_PCI_DEVICE_TABLE(i40evf_pci_tbl) = {
-	{PCI_VDEVICE(INTEL, I40E_VF_DEVICE_ID), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF), 0},
 	/* required last entry */
 	{0, }
 };
-- 
1.8.5.GIT
