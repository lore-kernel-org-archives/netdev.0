From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] fm10k: use true/false for boolean get_host_state
Date: Tue, 22 Dec 2015 06:02:10 -0800
Message-ID: <1450792932-96015-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753609AbbLVODP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:15 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9c6ed88..4eb7a6f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -912,7 +912,7 @@ static irqreturn_t fm10k_msix_mbx_vf(int __always_unused irq, void *data)
 		fm10k_mbx_unlock(interface);
 	}
 
-	hw->mac.get_host_state = 1;
+	hw->mac.get_host_state = true;
 	fm10k_service_event_schedule(interface);
 
 	return IRQ_HANDLED;
@@ -1128,7 +1128,7 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 	}
 
 	/* we should validate host state after interrupt event */
-	hw->mac.get_host_state = 1;
+	hw->mac.get_host_state = true;
 
 	/* validate host state, and handle VF mailboxes in the service task */
 	fm10k_service_event_schedule(interface);
@@ -1635,7 +1635,7 @@ void fm10k_up(struct fm10k_intfc *interface)
 	netif_tx_start_all_queues(interface->netdev);
 
 	/* kick off the service timer now */
-	hw->mac.get_host_state = 1;
+	hw->mac.get_host_state = true;
 	mod_timer(&interface->service_timer, jiffies);
 }
 
-- 
2.5.0
