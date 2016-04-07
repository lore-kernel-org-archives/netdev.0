From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: Inserting a HW capability display info
Date: Wed,  6 Apr 2016 20:29:26 -0700
Message-ID: <1459999779-22254-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Deepthi Kavalur <deepthi.kavalur@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9491 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbcDGD3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:42 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepthi Kavalur <deepthi.kavalur@intel.com>

Display MSIx vector count for HW capabilities.

Change-ID: I4b41e9b50360cf660e7fbcb85b9390fedcf313b1
Signed-off-by: Deepthi Kavalur <deepthi.kavalur@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index ebcc0d3..f3c1d88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3080,6 +3080,9 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 			break;
 		case I40E_AQ_CAP_ID_MSIX:
 			p->num_msix_vectors = number;
+			i40e_debug(hw, I40E_DEBUG_INIT,
+				   "HW Capability: MSIX vector count = %d\n",
+				   p->num_msix_vectors);
 			break;
 		case I40E_AQ_CAP_ID_VF_MSIX:
 			p->num_msix_vectors_vf = number;
-- 
2.5.5
