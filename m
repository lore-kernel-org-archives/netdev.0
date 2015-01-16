From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/17] i40e: Dump Stats string removed from debugfs help command
Date: Fri, 16 Jan 2015 05:28:55 -0800
Message-ID: <1421414946-22179-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sravanthi Tangeda <sravanthi.tangeda@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5726 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755478AbbAPN3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 08:29:17 -0500
In-Reply-To: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sravanthi Tangeda <sravanthi.tangeda@intel.com>

Dump Stats string has been removed from functional debugfs
help message. Now it does not show up when we echo command to
debugfs/Fortville queue.

Change-ID: I9333473826b574f1afa6ddb785fd7adfbdcb2884
Signed-off-by: Sravanthi Tangeda <sravanthi.tangeda@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index cb0de45..61236f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1890,7 +1890,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
 		dev_info(&pf->pdev->dev, "  dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
 		dev_info(&pf->pdev->dev, "  dump desc aq\n");
-		dev_info(&pf->pdev->dev, "  dump stats\n");
 		dev_info(&pf->pdev->dev, "  dump reset stats\n");
 		dev_info(&pf->pdev->dev, "  msg_enable [level]\n");
 		dev_info(&pf->pdev->dev, "  read <reg>\n");
-- 
1.9.3
