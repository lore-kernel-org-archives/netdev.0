From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/8] ixgbe: add support for QSFP PHY types in ixgbe_get_settings()
Date: Tue, 29 Dec 2015 19:23:24 -0800
Message-ID: <1451445809-70497-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27547 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916AbbL3DXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:23:34 -0500
In-Reply-To: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add missing QSFP PHY types to allow for more accurate reporting of
port settings.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1ed4c9a..e10d197 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -225,6 +225,10 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	case ixgbe_phy_sfp_avago:
 	case ixgbe_phy_sfp_intel:
 	case ixgbe_phy_sfp_unknown:
+	case ixgbe_phy_qsfp_passive_unknown:
+	case ixgbe_phy_qsfp_active_unknown:
+	case ixgbe_phy_qsfp_intel:
+	case ixgbe_phy_qsfp_unknown:
 		/* SFP+ devices, further checking needed */
 		switch (adapter->hw.phy.sfp_type) {
 		case ixgbe_sfp_type_da_cu:
-- 
2.5.0
