From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/14] i40e: fix a stray print message
Date: Tue, 24 Jun 2014 18:26:16 -0700
Message-ID: <1403659585-32055-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35161 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754258AbaFYB0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:38 -0400
In-Reply-To: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This log print message will probably never be seen, but it needs to match
the "attempting to rebuild switch\n" log message a few lines above.

Change-ID: Ic3f5b4f67568d721cb02e826cf2cb33847f51c11
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4289ff1..b4278a2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5775,7 +5775,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 
 	if (pf->vsi[pf->lan_vsi]->uplink_seid == pf->mac_seid) {
-		dev_info(&pf->pdev->dev, "attempting to rebuild PF VSI\n");
+		dev_dbg(&pf->pdev->dev, "attempting to rebuild PF VSI\n");
 		/* no VEB, so rebuild only the Main VSI */
 		ret = i40e_add_vsi(pf->vsi[pf->lan_vsi]);
 		if (ret) {
-- 
1.9.3
