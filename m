From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] i40e: fix sparse non static symbol warning
Date: Tue, 12 Aug 2014 01:38:23 -0700
Message-ID: <1407832707-26034-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53382 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbaHLIif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:35 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warnings:

drivers/net/ethernet/intel/i40e/i40e_nvm.c:254:13: warning:
 symbol 'i40e_write_nvm_aq' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 97bda3d..25c4f9a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -251,9 +251,9 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
  *
  * Writes a 16 bit words buffer to the Shadow RAM using the admin command.
  **/
-i40e_status i40e_write_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
-			      u32 offset, u16 words, void *data,
-			      bool last_command)
+static i40e_status i40e_write_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
+				     u32 offset, u16 words, void *data,
+				     bool last_command)
 {
 	i40e_status ret_code = I40E_ERR_NVM;
 
-- 
1.9.3
