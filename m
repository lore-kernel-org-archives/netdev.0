From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: count allocation errors
Date: Wed, 17 Feb 2016 09:51:41 -0800
Message-ID: <1455731506-62165-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161643AbcBQRvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:52 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Driver already counted allocation errors, so print
them as part of the ethtool -S output.  Useful for debugging
if your system is having trouble making memory available for
the driver.

Change-ID: I83839fa86e81e6d80f03b917c88dd3ef9a64dde0
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 812c954..9dcdf34 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -89,6 +89,8 @@ static const struct i40e_stats i40e_gstrings_misc_stats[] = {
 	I40E_VSI_STAT("rx_unknown_protocol", eth_stats.rx_unknown_protocol),
 	I40E_VSI_STAT("tx_linearize", tx_linearize),
 	I40E_VSI_STAT("tx_force_wb", tx_force_wb),
+	I40E_VSI_STAT("rx_alloc_fail", rx_buf_failed),
+	I40E_VSI_STAT("rx_pg_alloc_fail", rx_page_failed),
 };
 
 /* These PF_STATs might look like duplicates of some NETDEV_STATs,
-- 
2.5.0
