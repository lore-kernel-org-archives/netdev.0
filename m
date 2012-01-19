From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/9] igbvf: remove unneeded cast
Date: Thu, 19 Jan 2012 00:13:28 -0800
Message-ID: <1326960814-16976-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373Ab2ASINx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:53 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

The cast and comment are unnecessary in the current upstream kernel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Garrett, RobertX E <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 7b600a1..2dba534 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -468,6 +468,5 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 
 void igbvf_set_ethtool_ops(struct net_device *netdev)
 {
-	/* have to "undeclare" const on this struct to remove warnings */
-	SET_ETHTOOL_OPS(netdev, (struct ethtool_ops *)&igbvf_ethtool_ops);
+	SET_ETHTOOL_OPS(netdev, &igbvf_ethtool_ops);
 }
-- 
1.7.7.5
