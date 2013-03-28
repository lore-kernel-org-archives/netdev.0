From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] e1000e: enable EEE by default
Date: Thu, 28 Mar 2013 02:00:09 -0700
Message-ID: <1364461215-7793-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20438 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087Ab3C1JAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:23 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Now that IEEE802.3az-2010 Energy Efficient Ethernet has been approved as
standard (September 2010) and the driver can enable and disable it via
ethtool, enable the feature by default on parts which support it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 174507c..56c4935 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1034,10 +1034,6 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	    (er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
 		adapter->flags2 |= FLAG2_PCIM2PCI_ARBITER_WA;
 
-	/* Disable EEE by default until IEEE802.3az spec is finalized */
-	if (adapter->flags2 & FLAG2_HAS_EEE)
-		adapter->hw.dev_spec.ich8lan.eee_disable = true;
-
 	return 0;
 }
 
-- 
1.7.11.7
