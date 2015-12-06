From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/15] fm10k: TRIVIAL fix typo of hardware
Date: Sun,  6 Dec 2015 00:01:33 -0800
Message-ID: <1449388894-128573-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbbLFIBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:39 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
