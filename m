From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Remove unnecessary assignment
Date: Fri, 29 Aug 2014 02:30:09 -0700
Message-ID: <1409304620-23251-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53236 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbaH2JaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:25 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

Remove unnecessary setting of "ret" variable as it's already set at
the top of the function.

Change-ID: Icaccfc67f335817a23579b7c43625d59ad6c9925
Signed-off-by: Serey Kong <serey.kong@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4d8fd22..aeae5f2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2098,7 +2098,6 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	/* Force the VF driver stop so it has to reload with new MAC address */
 	i40e_vc_disable_vf(pf, vf);
 	dev_info(&pf->pdev->dev, "Reload the VF driver to make this change effective.\n");
-	ret = 0;
 
 error_param:
 	return ret;
-- 
1.9.3
