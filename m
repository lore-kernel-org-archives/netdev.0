From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: Fix wrong mask bits being used in misc interrupt
Date: Tue, 17 Dec 2013 22:44:34 -0800
Message-ID: <1387349082-18506-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779Ab3LRGoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:55 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

No functional change, but the wrong defines were being used.

Change-Id: Ica2afd2dfe18154ca0f1260a508f31e372319ba7
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fba0aad..994eb02 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2489,8 +2489,8 @@ static void i40e_enable_misc_int_causes(struct i40e_hw *hw)
 	wr32(hw, I40E_PFINT_ICR0_ENA, val);
 
 	/* SW_ITR_IDX = 0, but don't change INTENA */
-	wr32(hw, I40E_PFINT_DYN_CTL0, I40E_PFINT_DYN_CTLN_SW_ITR_INDX_MASK |
-					I40E_PFINT_DYN_CTLN_INTENA_MSK_MASK);
+	wr32(hw, I40E_PFINT_DYN_CTL0, I40E_PFINT_DYN_CTL0_SW_ITR_INDX_MASK |
+					I40E_PFINT_DYN_CTL0_INTENA_MSK_MASK);
 
 	/* OTHER_ITR_IDX = 0 */
 	wr32(hw, I40E_PFINT_STAT_CTL0, 0);
-- 
1.8.3.1
