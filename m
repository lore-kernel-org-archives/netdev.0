From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: fix a typo in i40e_pf documentation
Date: Fri,  6 Oct 2017 10:57:13 -0700
Message-ID: <20171006175727.868-2-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Rami Rosen <rami.rosen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752085AbdJFR5t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:49 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>

This patch fixes a typo in i40e_pf object documentation; num_req_vfs
refers to the number of VFs requested for the PF.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 439c63cb2a0c..2bc4dd0dbbf1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -350,7 +350,7 @@ struct i40e_pf {
 	u16 num_vmdq_vsis;         /* num vmdq vsis this PF has set up */
 	u16 num_vmdq_qps;          /* num queue pairs per vmdq pool */
 	u16 num_vmdq_msix;         /* num queue vectors per vmdq pool */
-	u16 num_req_vfs;           /* num VFs requested for this VF */
+	u16 num_req_vfs;           /* num VFs requested for this PF */
 	u16 num_vf_qps;            /* num queue pairs per VF */
 	u16 num_lan_qps;           /* num lan queues this PF has set up */
 	u16 num_lan_msix;          /* num queue vectors for the base PF vsi */
-- 
2.14.2
