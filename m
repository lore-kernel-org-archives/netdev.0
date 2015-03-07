From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Remove duplicate code
Date: Sat,  7 Mar 2015 07:03:10 -0800
Message-ID: <1425740603-11280-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbbCGPD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:27 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

This series of code was repeated twice, remove one of them.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 02672c3..0e4312f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9242,14 +9242,6 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 	pf->fc_autoneg_status = ((pf->hw.phy.link_info.an_info &
 				  I40E_AQ_AN_COMPLETED) ? true : false);
 
-	/* fill in link information and enable LSE reporting */
-	i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
-	i40e_link_event(pf);
-
-	/* Initialize user-specific link properties */
-	pf->fc_autoneg_status = ((pf->hw.phy.link_info.an_info &
-				  I40E_AQ_AN_COMPLETED) ? true : false);
-
 	i40e_ptp_init(pf);
 
 	return ret;
-- 
1.9.3
