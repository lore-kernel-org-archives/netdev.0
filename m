From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  09/10] ixgbe: include QSFP PHY types in ixgbe_is_sfp()
Date: Wed, 28 Aug 2013 03:33:47 -0700
Message-ID: <1377686028-30747-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48368 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664Ab3H1KeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 06:34:04 -0400
In-Reply-To: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
