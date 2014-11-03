From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] i40evf: Add support for 10G base T parts
Date: Mon,  3 Nov 2014 06:56:32 -0800
Message-ID: <1415026599-16232-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44876 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbaKCO4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:55 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

Add 10G-Base-T support in i40evf.

Change-ID: I98a1c3138d7d6572fe7903a7c1c4692cae3260d5
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 9525605..28c40c5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -50,6 +50,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_A:
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
+		case I40E_DEV_ID_10G_BASE_T:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_VF:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 1537643..8fe34fc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -43,6 +43,7 @@
 #define I40E_DEV_ID_QSFP_A		0x1583
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_VF		0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 
-- 
1.9.3
