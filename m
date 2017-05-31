From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] i40evf: fix duplicate lines
Date: Wed, 31 May 2017 03:48:48 -0700
Message-ID: <20170531104856.47929-2-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbdEaKtB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:01 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This removes two duplicate lines that snuck into the code somehow.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index deb2cb8dac6b..3cdac246d357 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -152,8 +152,6 @@ int i40evf_send_vf_config_msg(struct i40evf_adapter *adapter)
 {
 	u32 caps;
 
-	adapter->current_op = I40E_VIRTCHNL_OP_GET_VF_RESOURCES;
-	adapter->aq_required &= ~I40EVF_FLAG_AQ_GET_CONFIG;
 	caps = I40E_VIRTCHNL_VF_OFFLOAD_L2 |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG |
-- 
2.12.2
