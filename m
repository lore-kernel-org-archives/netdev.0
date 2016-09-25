From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: add encap csum VF offload flag
Date: Sat, 24 Sep 2016 23:42:37 -0700
Message-ID: <1474785769-54665-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbcIYGmw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:52 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Add ENCAP_CSUM offload negotiation flag. Currently VF assumes checksum
offload for encapsulated packets is supported by default. Going forward,
this feature needs to be negotiated with PF before advertising to the
stack. Hence, we need a flag to control it.
This is in regards to prepping up for VF base mode functionality support.

Change-ID: Iaab1f25cc0abda5f2fbe3309092640f0e77d163e
Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index c92a3bd..f861d31 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -163,6 +163,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index f04ce6c..bd691ad 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -160,6 +160,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
-- 
2.7.4
