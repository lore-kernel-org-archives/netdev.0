From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/6] i40e: make message meaningful
Date: Tue, 14 Jan 2014 00:49:51 -0800
Message-ID: <1389689394-22369-4-git-send-email-aaron.f.brown@intel.com>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbaANItr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:49:47 -0500
In-Reply-To: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Make this message mean something, rather than just spitting out a VSI id
without any context whatsoever.

Change-ID: Iafb906c6db46d4b5dcbe84adc9ed44730d08bd42
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 3868c11..53069c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -386,8 +386,8 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		vf->lan_vsi_index = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
 		dev_info(&pf->pdev->dev,
-			 "LAN VSI index %d, VSI id %d\n",
-			 vsi->idx, vsi->id);
+			 "VF %d assigned LAN VSI index %d, VSI id %d\n",
+			 vf->vf_id, vsi->idx, vsi->id);
 		/* If the port VLAN has been configured and then the
 		 * VF driver was removed then the VSI port VLAN
 		 * configuration was destroyed.  Check if there is
-- 
1.8.5.GIT
