From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: get rid of magic number
Date: Thu, 18 Feb 2016 01:03:58 -0800
Message-ID: <1455786252-71881-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14291 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425503AbcBRJEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:16 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We have a define for this, use it. No functional change.

Change-ID: Ic0e3ea4f562e46de63b2a8de07f291ccc10205fd
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 3e0d87e..597f209 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -461,7 +461,7 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_id,
 		rx_ctx.hbuff = info->hdr_size >> I40E_RXQ_CTX_HBUFF_SHIFT;
 
 		/* set splitalways mode 10b */
-		rx_ctx.dtype = 0x2;
+		rx_ctx.dtype = I40E_RX_DTYPE_HEADER_SPLIT;
 	}
 
 	/* databuffer length validation */
-- 
2.5.0
