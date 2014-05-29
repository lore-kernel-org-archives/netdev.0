From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: enable descriptor prefetch for VFs
Date: Thu, 29 May 2014 08:10:03 -0700
Message-ID: <1401376216-12531-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42446 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932496AbaE2PKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:36 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

As recommended by the hardware guys, enable descriptor prefetch for
rings belonging to VFs. This matches a change already made for ring
belonging to the PF.

Change-ID: Idcc4dc7064bc9144ea81f5701ad07b7ecd11ba49
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8564b09..7ab40ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -354,6 +354,7 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	rx_ctx.tphhead_ena = 1;
 	rx_ctx.lrxqthresh = 2;
 	rx_ctx.crcstrip = 1;
+	rx_ctx.prefena = 1;
 
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_rx_queue_context(hw, pf_queue_id);
-- 
1.9.3
