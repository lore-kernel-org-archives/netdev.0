From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: fix whitespace
Date: Thu,  3 Dec 2015 05:25:57 -0800
Message-ID: <1449149160-105219-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6976 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759721AbbLCN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:05 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Operators should have spaces around them.

Change-ID: I64735e9aa8618b9a5059a87ace1c999d6d3bfcfb
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 30a1d30..b3bd81c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -290,8 +290,8 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 	next_q = find_first_bit(&linklistmap,
 				(I40E_MAX_VSI_QP *
 				 I40E_VIRTCHNL_SUPPORTED_QTYPES));
-	vsi_queue_id = next_q/I40E_VIRTCHNL_SUPPORTED_QTYPES;
-	qtype = next_q%I40E_VIRTCHNL_SUPPORTED_QTYPES;
+	vsi_queue_id = next_q / I40E_VIRTCHNL_SUPPORTED_QTYPES;
+	qtype = next_q % I40E_VIRTCHNL_SUPPORTED_QTYPES;
 	pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_id, vsi_queue_id);
 	reg = ((qtype << I40E_VPINT_LNKLSTN_FIRSTQ_TYPE_SHIFT) | pf_queue_id);
 
-- 
2.5.0
