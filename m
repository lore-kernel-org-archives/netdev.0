From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/21] ixgbe: Fix reporting of 100Mb capability
Date: Fri, 30 Dec 2016 01:33:27 -0800
Message-ID: <20161230093341.14674-8-jeffrey.t.kirsher@intel.com>
References: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:60629 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752173AbcL3Jdq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 04:33:46 -0500
In-Reply-To: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

BaseT adapters that are capable of supporting 100Mb are not reporting this
capability.  This patch corrects the reporting so that 100Mb is shown as
supported on those adapters.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index fd192bf..8789f21 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -199,7 +199,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
 		ecmd->supported |= ixgbe_isbackplane(hw->phy.media_type) ?
 				   SUPPORTED_1000baseKX_Full :
-				   SUPPORTED_1000baseT_Full;
+				   SUPPORTED_100baseT_Full;
 
 	/* default advertised speed if phy.autoneg_advertised isn't set */
 	ecmd->advertising = ecmd->supported;
-- 
2.9.3
