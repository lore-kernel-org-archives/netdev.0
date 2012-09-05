From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] ixgbe: remove old init remnant
Date: Tue,  4 Sep 2012 23:25:50 -0700
Message-ID: <1346826350-27733-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346826350-27733-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51582 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab2IEG0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 02:26:50 -0400
In-Reply-To: <1346826350-27733-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Remove a for loop that does nothing in ixgbe_probe().
This is a remnant from when we had IO bars (compare to the ixgb code).

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fa0d6e1..1cbb34f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7169,11 +7169,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_ioremap;
 	}
 
-	for (i = 1; i <= 5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-	}
-
 	netdev->netdev_ops = &ixgbe_netdev_ops;
 	ixgbe_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
-- 
1.7.11.4
