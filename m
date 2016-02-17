From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Store lan_vsi_idx and lan_vsi_id in the right size
Date: Tue, 16 Feb 2016 21:34:12 -0800
Message-ID: <1455687262-20453-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pandi Maharajan <pandi.maharajan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756335AbcBQFe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:26 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pandi Maharajan <pandi.maharajan@intel.com>

lan_vsi_idx and lan_vsi_id are assigned to u16 data sized variables but
declared in u8. This patch fixes the width of the datatype.

Change-ID: If4bcbcc7d32f2b287c51cb33d17879691258dce2
Signed-off-by: Pandi Kumar Maharajan <pandi.maharajan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index da44995..e74642a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -91,8 +91,8 @@ struct i40e_vf {
 	 * When assigned, these will be non-zero, because VSI 0 is always
 	 * the main LAN VSI for the PF.
 	 */
-	u8 lan_vsi_idx;	        /* index into PF struct */
-	u8 lan_vsi_id;		/* ID as used by firmware */
+	u16 lan_vsi_idx;	/* index into PF struct */
+	u16 lan_vsi_id;		/* ID as used by firmware */
 
 	u8 num_queue_pairs;	/* num of qps assigned to VF vsis */
 	u64 num_mdd_events;	/* num of mdd events detected */
-- 
2.5.0
