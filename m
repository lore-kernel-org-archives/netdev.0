From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: Remove unnecessary prototypes
Date: Sun,  5 Jan 2014 02:47:06 -0800
Message-ID: <1388918827-13430-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5196 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbaAEKrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:17 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

These functions don't need a prototype as they are defined
in the file before they are called.

Change-Id: Ie17ffad4a29a9c0df434c4ebc4681128a6095c65
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 73f6faf..09d92d0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -517,13 +517,6 @@ struct rtnl_link_stats64 *i40e_get_vsi_stats_struct(struct i40e_vsi *vsi);
 int i40e_fetch_switch_configuration(struct i40e_pf *pf,
 				    bool printconfig);
 
-/* needed by i40e_main.c */
-void i40e_add_fdir_filter(struct i40e_fdir_data fdir_data,
-			  struct i40e_ring *tx_ring);
-void i40e_add_remove_filter(struct i40e_fdir_data fdir_data,
-			    struct i40e_ring *tx_ring);
-void i40e_update_fdir_filter(struct i40e_fdir_data fdir_data,
-			     struct i40e_ring *tx_ring);
 int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 			     struct i40e_pf *pf, bool add);
 
-- 
1.8.3.1
