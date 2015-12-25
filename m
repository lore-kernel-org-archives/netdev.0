From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: add support for QSFP PHY types in ixgbe_get_settings()
Date: Thu, 24 Dec 2015 21:29:50 -0800
Message-ID: <1451021396-68858-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbbLYF37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:29:59 -0500
In-Reply-To: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
