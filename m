From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Remove a FW workaround
Date: Tue, 22 Apr 2014 05:39:21 -0700
Message-ID: <1398170371-3333-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21423 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932603AbaDVMjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:37 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Remove the FW workaround to increment the number of msix vectors.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7f16f12..7beef10 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5223,9 +5223,6 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 		}
 	} while (err);
 
-	/* increment MSI-X count because current FW skips one */
-	pf->hw.func_caps.num_msix_vectors++;
-
 	if (((pf->hw.aq.fw_maj_ver == 2) && (pf->hw.aq.fw_min_ver < 22)) ||
 	    (pf->hw.aq.fw_maj_ver < 2)) {
 		pf->hw.func_caps.num_msix_vectors++;
-- 
1.9.0
