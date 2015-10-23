From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e: clean up local variable initialization
Date: Fri, 23 Oct 2015 06:17:55 -0700
Message-ID: <1445606279-19345-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60580 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943AbbJWNSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:18 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

In both i40e_calc_nvm_checksum() and i40e_update_nvm_checksum(), the
local variables designated by 'ret_code' are overwritten immediately. As
such, they should merely be declared.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 58e384a..1715358 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -484,7 +484,7 @@ static i40e_status i40e_write_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
 static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 						    u16 *checksum)
 {
-	i40e_status ret_code = 0;
+	i40e_status ret_code;
 	struct i40e_virt_mem vmem;
 	u16 pcie_alt_module = 0;
 	u16 checksum_local = 0;
@@ -564,7 +564,7 @@ i40e_calc_nvm_checksum_exit:
  **/
 i40e_status i40e_update_nvm_checksum(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
+	i40e_status ret_code;
 	u16 checksum;
 	__le16 le_sum;
 
-- 
2.4.3
