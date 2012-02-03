From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] ixgbe: make ethtool strings table const
Date: Fri,  3 Feb 2012 03:14:59 -0800
Message-ID: <1328267703-9638-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1774 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755690Ab2BCLPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 06:15:18 -0500
In-Reply-To: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1fd510c..1f31a04 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -58,7 +58,7 @@ struct ixgbe_stats {
 				sizeof(((struct rtnl_link_stats64 *)0)->m), \
 				offsetof(struct rtnl_link_stats64, m)
 
-static struct ixgbe_stats ixgbe_gstrings_stats[] = {
+static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBE_NETDEV_STAT(rx_packets)},
 	{"tx_packets", IXGBE_NETDEV_STAT(tx_packets)},
 	{"rx_bytes", IXGBE_NETDEV_STAT(rx_bytes)},
-- 
1.7.7.6
