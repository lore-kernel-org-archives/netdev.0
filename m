From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40e: group base mode VF offload flags
Date: Sat, 29 Oct 2016 00:30:48 -0700
Message-ID: <1477726258-111563-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12932 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752312AbcJ2HbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:09 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Group together the minimum set of offload capabilities that are always
supported by VF in base mode. This define would be used by PF to make
sure VF in base mode gets minimum of base capabilities .

Change-ID: Id5e8f22ba169c8f0a38d22fc36b2cb531c02582c
Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index f861d31..974ba2b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -165,6 +165,10 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
 #define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
 
+#define I40E_VF_BASE_MODE_OFFLOADS (I40E_VIRTCHNL_VF_OFFLOAD_L2 | \
+				    I40E_VIRTCHNL_VF_OFFLOAD_VLAN | \
+				    I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF)
+
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
 	u16 num_queue_pairs;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index bd691ad..fc374f8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -162,6 +162,10 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
 #define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
 
+#define I40E_VF_BASE_MODE_OFFLOADS (I40E_VIRTCHNL_VF_OFFLOAD_L2 | \
+				    I40E_VIRTCHNL_VF_OFFLOAD_VLAN | \
+				    I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF)
+
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
 	u16 num_queue_pairs;
-- 
2.7.4
