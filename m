From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: use correct format for printing MAC addresses
Date: Sun,  8 Jun 2014 07:33:49 -0700
Message-ID: <1402238037-20661-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64920 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbaFHOeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:05 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The correct format is %pM, not %pMAC.

Change-ID: Idb335723a966fe56db3a72b9c07c08ca66f9db3c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5fd60dd..590a9a4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2058,7 +2058,7 @@ static void i40evf_init_task(struct work_struct *work)
 	netdev->hw_features &= ~NETIF_F_RXCSUM;
 
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
-		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using random\n",
+		dev_info(&pdev->dev, "Invalid MAC address %pM, using random\n",
 			 adapter->hw.mac.addr);
 		random_ether_addr(adapter->hw.mac.addr);
 	}
@@ -2116,7 +2116,7 @@ static void i40evf_init_task(struct work_struct *work)
 
 	netif_tx_stop_all_queues(netdev);
 
-	dev_info(&pdev->dev, "MAC address: %pMAC\n", adapter->hw.mac.addr);
+	dev_info(&pdev->dev, "MAC address: %pM\n", adapter->hw.mac.addr);
 	if (netdev->features & NETIF_F_GRO)
 		dev_info(&pdev->dev, "GRO is enabled\n");
 
-- 
1.9.3
