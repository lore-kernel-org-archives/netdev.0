From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e: AQ Add VXLAN-GPE tunnel type
Date: Tue, 16 Feb 2016 21:34:09 -0800
Message-ID: <1455687262-20453-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263AbcBQFe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:26 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new Cisco VXLAN-GPE cloud tunnel type for the Add Cloud Filter
and UDP tunnel AQ commands.

Change-ID: I2c093c7d79726c7fca08a36e5c63581a905da3d2
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 3 +++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 7e96615..5effb91 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1278,6 +1278,8 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_NVGRE_OMAC		1
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_RESERVED		4
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_VXLAN_GPE		5
 
 #define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_MAC	0x2000
 #define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_INNER_MAC	0x4000
@@ -2229,6 +2231,7 @@ struct i40e_aqc_add_udp_tunnel {
 #define I40E_AQC_TUNNEL_TYPE_VXLAN	0x00
 #define I40E_AQC_TUNNEL_TYPE_NGE	0x01
 #define I40E_AQC_TUNNEL_TYPE_TEREDO	0x10
+#define I40E_AQC_TUNNEL_TYPE_VXLAN_GPE	0x11
 	u8	reserved1[10];
 };
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 2c8f3ed..bdb18f6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1275,6 +1275,8 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_NVGRE_OMAC		1
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_RESERVED		4
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_VXLAN_GPE		5
 
 #define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_MAC	0x2000
 #define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_INNER_MAC	0x4000
@@ -2121,6 +2123,7 @@ struct i40e_aqc_add_udp_tunnel {
 #define I40E_AQC_TUNNEL_TYPE_VXLAN	0x00
 #define I40E_AQC_TUNNEL_TYPE_NGE	0x01
 #define I40E_AQC_TUNNEL_TYPE_TEREDO	0x10
+#define I40E_AQC_TUNNEL_TYPE_VXLAN_GPE	0x11
 	u8	reserved1[10];
 };
 
-- 
2.5.0
