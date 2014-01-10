From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40e: fix log message wording
Date: Fri, 10 Jan 2014 00:58:55 -0800
Message-ID: <1389344336-1558-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1468 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbaAJI7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 03:59:07 -0500
In-Reply-To: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Change the redundant "vsi VSI" to VSI.

Change-ID: Ic16ea5820a99abc7831713cde39e7d032a7ba4d3
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0220b18..36a5cc8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1083,7 +1083,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev,
-				 "add relay: vsi VSI %d not found\n", vsi_seid);
+				 "add relay: VSI %d not found\n", vsi_seid);
 			goto command_write_done;
 		}
 
-- 
1.8.3.1
