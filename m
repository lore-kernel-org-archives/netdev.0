From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: use kernel specific defines
Date: Thu,  9 Jan 2014 04:52:11 -0800
Message-ID: <1389271944-26227-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55960 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886AbaAIMw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:29 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Replace uses of I40E_LENGTH_OF_ADDRESS with ETH_ALEN.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 8 +++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h | 4 ++--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index bcf0317..53c40cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -77,8 +77,6 @@
 struct i40e_hw;
 typedef void (*I40E_ADMINQ_CALLBACK)(struct i40e_hw *, struct i40e_aq_desc *);
 
-#define I40E_ETH_LENGTH_OF_ADDRESS	6
-
 /* Data type manipulation macros. */
 
 #define I40E_DESC_UNUSED(R)	\
@@ -240,9 +238,9 @@ struct i40e_hw_capabilities {
 
 struct i40e_mac_info {
 	enum i40e_mac_type type;
-	u8 addr[I40E_ETH_LENGTH_OF_ADDRESS];
-	u8 perm_addr[I40E_ETH_LENGTH_OF_ADDRESS];
-	u8 san_addr[I40E_ETH_LENGTH_OF_ADDRESS];
+	u8 addr[ETH_ALEN];
+	u8 perm_addr[ETH_ALEN];
+	u8 san_addr[ETH_ALEN];
 	u16 max_fcoeq;
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index cc6654f..6bcfcef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -142,7 +142,7 @@ struct i40e_virtchnl_vsi_resource {
 	u16 num_queue_pairs;
 	enum i40e_vsi_type vsi_type;
 	u16 qset_handle;
-	u8 default_mac_addr[I40E_ETH_LENGTH_OF_ADDRESS];
+	u8 default_mac_addr[ETH_ALEN];
 };
 /* VF offload flags */
 #define I40E_VIRTCHNL_VF_OFFLOAD_L2	0x00000001
@@ -265,7 +265,7 @@ struct i40e_virtchnl_queue_select {
  */
 
 struct i40e_virtchnl_ether_addr {
-	u8 addr[I40E_ETH_LENGTH_OF_ADDRESS];
+	u8 addr[ETH_ALEN];
 	u8 pad[2];
 };
 
-- 
1.8.3.1
