From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/16] i40e: print neato new features
Date: Thu,  8 Oct 2015 18:32:54 -0700
Message-ID: <1444354374-24351-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23167 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755611AbbJIBdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:04 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

To help users and developers know what compile options
and hardware features are enabled at compile time, print
VxLAN is available.

Change-ID: I3162f3b7678dc725a597f964217920eb218b480b
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c46d814..a484f22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9914,6 +9914,9 @@ static void i40e_print_features(struct i40e_pf *pf)
 	}
 	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
 		buf += sprintf(buf, "DCB ");
+#if IS_ENABLED(CONFIG_VXLAN)
+	buf += sprintf(buf, "VxLAN ");
+#endif
 	if (pf->flags & I40E_FLAG_PTP)
 		buf += sprintf(buf, "PTP ");
 #ifdef I40E_FCOE
-- 
2.4.3
