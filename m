From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/18] i40e: change message to only appear when extra debug info is wanted
Date: Sat,  3 Dec 2016 01:19:30 -0800
Message-ID: <20161203091930.14268-19-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23645 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751488AbcLCJUe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:34 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes an X722 informational message so that it only
appears when extra messages are desired.  Without this patch,
on X722 devices, this message appears at load, potentially causing
unnecessary alarm.

Change-ID: I94f7aae15dc5b2723cc9728c630c72538a3e670e
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 594856d..5777e49 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3579,7 +3579,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	    (ena_mask & I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK)) {
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
 		icr0 &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
-		dev_info(&pf->pdev->dev, "cleared PE_CRITERR\n");
+		dev_dbg(&pf->pdev->dev, "cleared PE_CRITERR\n");
 	}
 
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
-- 
2.9.3
