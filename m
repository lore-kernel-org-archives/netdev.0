From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e/i40evf: update WOL and I40E_AQC_ADDR_VALID_MASK flags
Date: Tue, 20 Jun 2017 18:17:51 -0700
Message-ID: <20170621011802.81768-5-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Alice Michael <alice.michael@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:4752 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753118AbdFUBSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:16 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alice Michael <alice.michael@intel.com>

Update a few flags related to FW interactions.

Copyright updated to 2017.

Signed-off-by: Alice Michael <alice.michael@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5eb04114e13f..5d5f422cbae5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2016 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -531,7 +531,7 @@ struct i40e_aqc_mac_address_read {
 #define I40E_AQC_PORT_ADDR_VALID	0x40
 #define I40E_AQC_WOL_ADDR_VALID		0x80
 #define I40E_AQC_MC_MAG_EN_VALID	0x100
-#define I40E_AQC_ADDR_VALID_MASK	0x1F0
+#define I40E_AQC_ADDR_VALID_MASK	0x3F0
 	u8	reserved[6];
 	__le32	addr_high;
 	__le32	addr_low;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 91d8786d386d..83e63e55c4b4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 - 2016 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -528,7 +528,7 @@ struct i40e_aqc_mac_address_read {
 #define I40E_AQC_PORT_ADDR_VALID	0x40
 #define I40E_AQC_WOL_ADDR_VALID		0x80
 #define I40E_AQC_MC_MAG_EN_VALID	0x100
-#define I40E_AQC_ADDR_VALID_MASK	0x1F0
+#define I40E_AQC_ADDR_VALID_MASK	0x3F0
 	u8	reserved[6];
 	__le32	addr_high;
 	__le32	addr_low;
@@ -586,6 +586,7 @@ struct i40e_aqc_set_wol_filter {
 	__le16 cmd_flags;
 #define I40E_AQC_SET_WOL_FILTER				0x8000
 #define I40E_AQC_SET_WOL_FILTER_NO_TCO_WOL		0x4000
+#define I40E_AQC_SET_WOL_FILTER_WOL_PRESERVE_ON_PFR	0x2000
 #define I40E_AQC_SET_WOL_FILTER_ACTION_CLEAR		0
 #define I40E_AQC_SET_WOL_FILTER_ACTION_SET		1
 	__le16 valid_flags;
-- 
2.12.2
