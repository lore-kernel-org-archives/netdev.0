From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40e: count drops in netstat interface
Date: Wed, 30 Sep 2015 05:52:31 -0700
Message-ID: <1443617561-40490-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34535 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932342AbbI3Mwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:45 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The i40e rx_dropped counter was not showing up in netstat -i.
Add the right counter to be updated with the stats.

Change-ID: I4dd552e9995836099184f9d9a08e90edb591155f
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index dce7d85..3a3d49c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -474,6 +474,7 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	stats->tx_errors	= vsi_stats->tx_errors;
 	stats->tx_dropped	= vsi_stats->tx_dropped;
 	stats->rx_errors	= vsi_stats->rx_errors;
+	stats->rx_dropped	= vsi_stats->rx_dropped;
 	stats->rx_crc_errors	= vsi_stats->rx_crc_errors;
 	stats->rx_length_errors	= vsi_stats->rx_length_errors;
 
-- 
2.4.3
