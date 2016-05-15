From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: fix an uninitialized variable bug
Date: Sat, 14 May 2016 21:57:35 -0700
Message-ID: <1463288255-1654-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbcEOE5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:43 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We removed this initialization but it is required.  Let's put it back.

Fixes: 895106a577c4 ('i40e: trivial fixes')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_hmc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
index 5ebe12d..a7c7b1d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
@@ -49,7 +49,7 @@ i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
 	struct i40e_hmc_sd_entry *sd_entry;
 	bool dma_mem_alloc_done = false;
 	struct i40e_dma_mem mem;
-	i40e_status ret_code;
+	i40e_status ret_code = I40E_SUCCESS;
 	u64 alloc_len;
 
 	if (NULL == hmc_info->sd_table.sd_entry) {
-- 
2.5.5
