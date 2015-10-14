From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/16] i40e: remove redundant call
Date: Tue, 13 Oct 2015 23:59:47 -0700
Message-ID: <1444805996-3877-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27504 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbbJNHAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 03:00:00 -0400
In-Reply-To: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This function call isn't needed here; the same function is already
called by i40e_reset_vf.

Change-ID: I96ccbf91b752965c9e28fe895d4c7d4c46e3ba44
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ee747dc..2102280 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -964,8 +964,6 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* VF resources get allocated during reset */
 		i40e_reset_vf(&vfs[i], false);
 
-		/* enable VF vplan_qtable mappings */
-		i40e_enable_vf_mappings(&vfs[i]);
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
-- 
2.4.3
