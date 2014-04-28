From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: Change variable type to avoid typecheck failure
Date: Mon, 28 Apr 2014 06:52:33 -0700
Message-ID: <1398693158-2815-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59462 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbaD1Nwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:47 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Change the variable type to avoid compiler warning about int to u16
possible data truncation.

Change-ID: I5eb3b578c86513c9625ca32d2f0b57cc01d7dc98
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index fde5aef..e19df8f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1300,7 +1300,7 @@ i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
 	struct i40e_aqc_driver_version *cmd =
 		(struct i40e_aqc_driver_version *)&desc.params.raw;
 	i40e_status status;
-	int len;
+	u16 len;
 
 	if (dv == NULL)
 		return I40E_ERR_PARAM;
-- 
1.9.0
