From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] e1000e: cleanup - use braces in both branches of a conditional statement
Date: Tue,  7 Feb 2012 04:33:55 -0800
Message-ID: <1328618038-5008-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40692 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756140Ab2BGMeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:15 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c05137f..02efae0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3756,8 +3756,9 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
 		e_info("MSI interrupt test failed, using legacy interrupt.\n");
-	} else
+	} else {
 		e_dbg("MSI interrupt test succeeded!\n");
+	}
 
 	free_irq(adapter->pdev->irq, netdev);
 	pci_disable_msi(adapter->pdev);
-- 
1.7.7.6
