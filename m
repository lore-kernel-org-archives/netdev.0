From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] i40e: remove forever unused ID
Date: Fri,  8 Jan 2016 02:14:43 -0800
Message-ID: <1452248083-78628-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16868 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbcAHKO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 05:14:58 -0500
In-Reply-To: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Somehow an ID that has never been productized is in the
code.  There are no plans to use it, so just get
rid of it.

Change-ID: I59117d48ea9ee0360b0fe33833ac8092f8a24b4c
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
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
index 2d74c6e..6a034dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -44,7 +44,6 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		switch (hw->device_id) {
 		case I40E_DEV_ID_SFP_XL710:
 		case I40E_DEV_ID_QEMU:
-		case I40E_DEV_ID_KX_A:
 		case I40E_DEV_ID_KX_B:
 		case I40E_DEV_ID_KX_C:
 		case I40E_DEV_ID_QSFP_A:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_devids.h b/drivers/net/ethernet/intel/i40e/i40e_devids.h
index c601ca4..448ef4c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_devids.h
@@ -30,7 +30,6 @@
 /* Device IDs */
 #define I40E_DEV_ID_SFP_XL710		0x1572
 #define I40E_DEV_ID_QEMU		0x1574
-#define I40E_DEV_ID_KX_A		0x157F
 #define I40E_DEV_ID_KX_B		0x1580
 #define I40E_DEV_ID_KX_C		0x1581
 #define I40E_DEV_ID_QSFP_A		0x1583
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2914806..bb4612c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -82,7 +82,6 @@ static int i40e_veb_get_bw_info(struct i40e_veb *veb);
 static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_SFP_XL710), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QEMU), 0},
-	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_A), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_KX_C), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_A), 0},
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 72b1942..938783e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -44,7 +44,6 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		switch (hw->device_id) {
 		case I40E_DEV_ID_SFP_XL710:
 		case I40E_DEV_ID_QEMU:
-		case I40E_DEV_ID_KX_A:
 		case I40E_DEV_ID_KX_B:
 		case I40E_DEV_ID_KX_C:
 		case I40E_DEV_ID_QSFP_A:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_devids.h b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
index e6a39c9..ca8b58c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
@@ -30,7 +30,6 @@
 /* Device IDs */
 #define I40E_DEV_ID_SFP_XL710		0x1572
 #define I40E_DEV_ID_QEMU		0x1574
-#define I40E_DEV_ID_KX_A		0x157F
 #define I40E_DEV_ID_KX_B		0x1580
 #define I40E_DEV_ID_KX_C		0x1581
 #define I40E_DEV_ID_QSFP_A		0x1583
-- 
2.5.0
