From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/10] i40e: removed no longer needed delays
Date: Mon, 27 Mar 2017 16:52:05 -0700
Message-ID: <20170327235210.28652-6-jeffrey.t.kirsher@intel.com>
References: <20170327235210.28652-1-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27157 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753428AbdC0Xwi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 19:52:38 -0400
In-Reply-To: <20170327235210.28652-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

Removed no longer needed delays.  At preproduction stage those delays were
needed but now these delays are not needed.

Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5da990909a88..0359f60b4792 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4101,8 +4101,6 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		}
 	}
 
-	if (hw->revision_id == 0)
-		mdelay(50);
 	return ret;
 }
 
-- 
2.12.0
