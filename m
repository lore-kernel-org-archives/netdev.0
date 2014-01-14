From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 5/6] i40e: trivial cleanup
Date: Tue, 14 Jan 2014 00:49:53 -0800
Message-ID: <1389689394-22369-6-git-send-email-aaron.f.brown@intel.com>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbaANItu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:49:50 -0500
In-Reply-To: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Remove some un-necessary parenthesis.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 101ed41..d5d98fe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -485,8 +485,7 @@ i40e_status i40e_configure_lan_hmc(struct i40e_hw *hw,
 		/* Make one big object, a single SD */
 		info.count = 1;
 		ret_code = i40e_create_lan_hmc_object(hw, &info);
-		if ((ret_code) &&
-		    (model == I40E_HMC_MODEL_DIRECT_PREFERRED))
+		if (ret_code && (model == I40E_HMC_MODEL_DIRECT_PREFERRED))
 			goto try_type_paged;
 		else if (ret_code)
 			goto configure_lan_hmc_out;
-- 
1.8.5.GIT
