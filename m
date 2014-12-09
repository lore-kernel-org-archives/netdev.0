From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/13] i40e: add to NVM update debug message
Date: Tue,  9 Dec 2014 13:26:19 -0800
Message-ID: <1418160380-29847-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56965 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbaLIV07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:59 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add a little more state context to an NVM update debug message.

Change-ID: I512160259052bcdbe5bdf1adf403ab2bf7984970
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 1613ef4..3e70f2e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -806,8 +806,10 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		}
 		break;
 	}
-	i40e_debug(hw, I40E_DEBUG_NVM, "%s\n",
-		   i40e_nvm_update_state_str[upd_cmd]);
+	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d\n",
+		   i40e_nvm_update_state_str[upd_cmd],
+		   hw->nvmupd_state,
+		   hw->aq.nvm_release_on_done);
 
 	if (upd_cmd == I40E_NVMUPD_INVALID) {
 		*errno = -EFAULT;
-- 
1.9.3
