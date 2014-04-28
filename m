From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40evf: remove debugging message
Date: Mon, 28 Apr 2014 06:52:32 -0700
Message-ID: <1398693158-2815-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7567 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbaD1Nwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:46 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the PF driver fails or is removed from the host, the VF driver will
fill up its log with this message.

Change-ID: I67045f987f7c0d444d21ded403adc509343cdb8f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d7abd0d..0a4ff41 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1311,7 +1311,6 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		goto restart_watchdog;
 
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED) {
-		dev_info(&adapter->pdev->dev, "Checking for redemption\n");
 		if ((rd32(hw, I40E_VFGEN_RSTAT) & 0x3) == I40E_VFR_VFACTIVE) {
 			/* A chance for redemption! */
 			dev_err(&adapter->pdev->dev, "Hardware came out of reset. Attempting reinit.\n");
-- 
1.9.0
