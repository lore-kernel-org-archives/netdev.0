From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] fm10k: TRIVIAL fix typo of hardware
Date: Thu,  3 Dec 2015 16:29:53 -0800
Message-ID: <1449188994-64940-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14336 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994AbbLDAaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:30:00 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 0cdb79e8..15d8e10 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -584,7 +584,7 @@ static void fm10k_configure_tx_ring(struct fm10k_intfc *interface,
 	/* store tail pointer */
 	ring->tail = &interface->uc_addr[FM10K_TDT(reg_idx)];
 
-	/* reset ntu and ntc to place SW in sync with hardwdare */
+	/* reset ntu and ntc to place SW in sync with hardware */
 	ring->next_to_clean = 0;
 	ring->next_to_use = 0;
 
@@ -690,7 +690,7 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	/* store tail pointer */
 	ring->tail = &interface->uc_addr[FM10K_RDT(reg_idx)];
 
-	/* reset ntu and ntc to place SW in sync with hardwdare */
+	/* reset ntu and ntc to place SW in sync with hardware */
 	ring->next_to_clean = 0;
 	ring->next_to_use = 0;
 	ring->next_to_alloc = 0;
-- 
2.5.0
