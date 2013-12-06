From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: sync header files with hardware
Date: Fri,  6 Dec 2013 00:06:28 -0800
Message-ID: <1386317188-13944-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab3LFIGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:37 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Update the PCTYPE table
fix fcoe HMC object sizes

Change-Id: I1f12cd2653168859661e8700f929b7c65b0e21b7
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_type.h    | 11 ++++-------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
index 00ff35006..f8afbcb0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
@@ -113,8 +113,8 @@ enum i40e_hmc_lan_object_size {
 #define I40E_HMC_L2OBJ_BASE_ALIGNMENT 512
 #define I40E_HMC_OBJ_SIZE_TXQ         128
 #define I40E_HMC_OBJ_SIZE_RXQ         32
-#define I40E_HMC_OBJ_SIZE_FCOE_CNTX   128
-#define I40E_HMC_OBJ_SIZE_FCOE_FILT   32
+#define I40E_HMC_OBJ_SIZE_FCOE_CNTX   64
+#define I40E_HMC_OBJ_SIZE_FCOE_FILT   64
 
 enum i40e_hmc_lan_rsrc_type {
 	I40E_HMC_LAN_FULL  = 0,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index f3f22b2..5f81bd5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -852,10 +852,7 @@ struct i40e_filter_program_desc {
 
 /* Packet Classifier Types for filters */
 enum i40e_filter_pctype {
-	/* Note: Value 0-25 are reserved for future use */
-	I40E_FILTER_PCTYPE_IPV4_TEREDO_UDP		= 26,
-	I40E_FILTER_PCTYPE_IPV6_TEREDO_UDP		= 27,
-	I40E_FILTER_PCTYPE_NONF_IPV4_1588_UDP		= 28,
+	/* Note: Values 0-28 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP	= 29,
 	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP	= 30,
 	I40E_FILTER_PCTYPE_NONF_IPV4_UDP		= 31,
@@ -864,8 +861,7 @@ enum i40e_filter_pctype {
 	I40E_FILTER_PCTYPE_NONF_IPV4_SCTP		= 34,
 	I40E_FILTER_PCTYPE_NONF_IPV4_OTHER		= 35,
 	I40E_FILTER_PCTYPE_FRAG_IPV4			= 36,
-	/* Note: Value 37 is reserved for future use */
-	I40E_FILTER_PCTYPE_NONF_IPV6_1588_UDP		= 38,
+	/* Note: Values 37-38 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP	= 39,
 	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP	= 40,
 	I40E_FILTER_PCTYPE_NONF_IPV6_UDP		= 41,
@@ -877,7 +873,8 @@ enum i40e_filter_pctype {
 	/* Note: Value 47 is reserved for future use */
 	I40E_FILTER_PCTYPE_FCOE_OX			= 48,
 	I40E_FILTER_PCTYPE_FCOE_RX			= 49,
-	/* Note: Value 50-62 are reserved for future use */
+	I40E_FILTER_PCTYPE_FCOE_OTHER			= 50,
+	/* Note: Values 51-62 are reserved for future use */
 	I40E_FILTER_PCTYPE_L2_PAYLOAD			= 63,
 };
 
-- 
1.8.3.1
