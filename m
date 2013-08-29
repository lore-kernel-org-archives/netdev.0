From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/10] ixgbe: include QSFP PHY types in ixgbe_is_sfp()
Date: Thu, 29 Aug 2013 03:50:05 -0700
Message-ID: <1377773406-24851-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56411 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756297Ab3H2Kub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:50:31 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch makes sure that QSFP+ modules use the SFP+ code path for
setting up link.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4688057..7aba452 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4175,6 +4175,10 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
 	case ixgbe_phy_sfp_passive_unknown:
 	case ixgbe_phy_sfp_active_unknown:
 	case ixgbe_phy_sfp_ftl_active:
+	case ixgbe_phy_qsfp_passive_unknown:
+	case ixgbe_phy_qsfp_active_unknown:
+	case ixgbe_phy_qsfp_intel:
+	case ixgbe_phy_qsfp_unknown:
 		return true;
 	case ixgbe_phy_nl:
 		if (hw->mac.type == ixgbe_mac_82598EB)
-- 
1.8.3.1
