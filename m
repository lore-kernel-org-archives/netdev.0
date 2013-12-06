From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: fix debugging messages
Date: Fri,  6 Dec 2013 00:06:23 -0800
Message-ID: <1386317188-13944-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab3LFIGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:36 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Clean up some messages that had arguments reversed.

Change-Id: I0f38a4f01132a2918d61dbaf23de1e1eaed5e56d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 5997301..e7bdd47 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -620,13 +620,13 @@ int i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		if (ret)
 			dev_info(&pf->pdev->dev,
 				 "Queue control check failed on Tx queue %d of VSI %d VF %d\n",
-				 vf->lan_vsi_index, j, vf->vf_id);
+				 j, vf->lan_vsi_index, vf->vf_id);
 		ret = i40e_ctrl_vsi_rx_queue(vf, vf->lan_vsi_index, j,
 					     I40E_QUEUE_CTRL_FASTDISABLECHECK);
 		if (ret)
 			dev_info(&pf->pdev->dev,
 				 "Queue control check failed on Rx queue %d of VSI %d VF %d\n",
-				 vf->lan_vsi_index, j, vf->vf_id);
+				 j, vf->lan_vsi_index, vf->vf_id);
 	}
 
 	/* clear the irq settings */
-- 
1.8.3.1
