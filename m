From: weiyj_lk@163.com
Subject: [PATCH -next] i40e: fix sparse non static symbol warning
Date: Wed, 30 Jul 2014 07:20:58 +0800
Message-ID: <1406676058-26461-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:45051 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbaG2XVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 19:21:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warnings:

drivers/net/ethernet/intel/i40e/i40e_nvm.c:254:13: warning:
 symbol 'i40e_write_nvm_aq' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
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
 
