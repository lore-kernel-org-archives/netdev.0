From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/9] i40e: fix compile warning on checksum_local
Date: Fri, 17 Jan 2014 15:36:31 -0800
Message-ID: <1390001799-19425-2-git-send-email-aaron.f.brown@intel.com>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55373 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897AbaAQXhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:37:01 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Compile testing with higher warning levels found this complaint: 
i40e_nvm.c: warning: 'checksum_local' may be used uninitialized in
this function

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index e12bf07..73f95b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -323,7 +323,7 @@ i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
 {
 	i40e_status ret_code = 0;
 	u16 checksum_sr = 0;
-	u16 checksum_local;
+	u16 checksum_local = 0;
 
 	ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
 	if (ret_code)
-- 
1.8.5.GIT
