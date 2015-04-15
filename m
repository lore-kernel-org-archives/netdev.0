From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: print FCoE capability reported by the device function
Date: Tue, 14 Apr 2015 21:51:45 -0700
Message-ID: <1429073511-27664-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10570 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932646AbbDOEwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:07 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

This is to allow quick check for FCoE capability is enabled or not
in device function before any SW overrides.

Change-ID: I5f78ba798d566f143161273156916c6f4074496e
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index d596f66..44dc4b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2546,6 +2546,9 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 		}
 	}
 
+	if (p->fcoe)
+		i40e_debug(hw, I40E_DEBUG_ALL, "device is FCoE capable\n");
+
 	/* Software override ensuring FCoE is disabled if npar or mfp
 	 * mode because it is not supported in these modes.
 	 */
-- 
1.9.3
