From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e/i40evf: remove deprecated device IDs
Date: Sun,  8 Jun 2014 07:33:56 -0700
Message-ID: <1402238037-20661-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64930 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753560AbaFHOeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:09 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Remove two device IDs 1582 and 1573, because they will not be shipped.

Change-ID: Ica2e550b5b21a69e3f353eba2fe5e1c532a548c4
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 2 --
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 --
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 2 --
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 2 --
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 4 +---
 5 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8bfb445..8e4b33c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -43,12 +43,10 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 	if (hw->vendor_id == PCI_VENDOR_ID_INTEL) {
 		switch (hw->device_id) {
 		case I40E_DEV_ID_SFP_XL710:
-		case I40E_DEV_ID_SFP_X710:
 		case I40E_DEV_ID_QEMU:
 		case I40E_DEV_ID_KX_A:
 		case I40E_DEV_ID_KX_B:
 		case I40E_DEV_ID_KX_C:
-		case I40E_DEV_ID_KX_D:
 		case I40E_DEV_ID_QSFP_A:
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 254bb68..8fc554d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -67,12 +67,10 @@ static int i40e_veb_get_bw_info(struct i40e_veb *veb);
  */
 static DEFINE_PCI_DEVICE_TABLE(i40e_pci_tbl) = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_XL710), 0},
-	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_X710), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QEMU), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_A), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_C), 0},
-	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_D), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_A), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 7fbbab4..6c977d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -36,12 +36,10 @@
 
 /* Device IDs */
 #define I40E_DEV_ID_SFP_XL710		0x1572
-#define I40E_DEV_ID_SFP_X710		0x1573
 #define I40E_DEV_ID_QEMU		0x1574
 #define I40E_DEV_ID_KX_A		0x157F
 #define I40E_DEV_ID_KX_B		0x1580
 #define I40E_DEV_ID_KX_C		0x1581
-#define I40E_DEV_ID_KX_D		0x1582
 #define I40E_DEV_ID_QSFP_A		0x1583
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index ea0f200..a43155a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -43,12 +43,10 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 	if (hw->vendor_id == PCI_VENDOR_ID_INTEL) {
 		switch (hw->device_id) {
 		case I40E_DEV_ID_SFP_XL710:
-		case I40E_DEV_ID_SFP_X710:
 		case I40E_DEV_ID_QEMU:
 		case I40E_DEV_ID_KX_A:
 		case I40E_DEV_ID_KX_B:
 		case I40E_DEV_ID_KX_C:
-		case I40E_DEV_ID_KX_D:
 		case I40E_DEV_ID_QSFP_A:
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 9c901fd..e3c9ebb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -35,13 +35,11 @@
 #include "i40e_lan_hmc.h"
 
 /* Device IDs */
-#define I40E_DEV_ID_SFP_XL710	0x1572
-#define I40E_DEV_ID_SFP_X710		0x1573
+#define I40E_DEV_ID_SFP_XL710		0x1572
 #define I40E_DEV_ID_QEMU		0x1574
 #define I40E_DEV_ID_KX_A		0x157F
 #define I40E_DEV_ID_KX_B		0x1580
 #define I40E_DEV_ID_KX_C		0x1581
-#define I40E_DEV_ID_KX_D		0x1582
 #define I40E_DEV_ID_QSFP_A		0x1583
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
-- 
1.9.3
