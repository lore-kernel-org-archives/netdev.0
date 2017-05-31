From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] i40evf: fix merge error in older patch
Date: Wed, 31 May 2017 03:48:49 -0700
Message-ID: <20170531104856.47929-3-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:24804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751114AbdEaKtB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:01 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch fixes a missing line that was missed while merging,
which results in a driver feature in the VF not working to
enable RSS as a negotiated feature.

Fixes: 43a3d9ba34c9c ("i40evf: Allow PF driver to configure RSS")
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 3cdac246d357..91b21f26f8d4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -153,6 +153,7 @@ int i40evf_send_vf_config_msg(struct i40evf_adapter *adapter)
 	u32 caps;
 
 	caps = I40E_VIRTCHNL_VF_OFFLOAD_L2 |
+	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG |
 	       I40E_VIRTCHNL_VF_OFFLOAD_VLAN |
-- 
2.12.2
