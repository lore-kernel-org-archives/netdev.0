From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/6] e100: fix spelling errors
Date: Fri, 01 Feb 2008 08:21:39 -0800
Message-ID: <20080201162139.29347.13326.stgit@localhost.localdomain>
References: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7770 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755728AbYBAQZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:25:53 -0500
In-Reply-To: <20080201162118.29347.13268.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>

Signed-off-by: Andreas Mohr <andi@lisas.de>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 9d42dd8..36ba6dc 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -94,7 +94,7 @@
  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
  * 	with 00h.
  *
- *	IV.  Recieve
+ *	IV.  Receive
  *
  *	The Receive Frame Area (RFA) comprises a ring of Receive Frame
  *	Descriptors (RFD) + data buffer, thus forming the simplified mode
@@ -120,7 +120,7 @@
  *	and Rx indication and re-allocation happen in the same context,
  *	therefore no locking is required.  A software-generated interrupt
  *	is generated from the watchdog to recover from a failed allocation
- *	senario where all Rx resources have been indicated and none re-
+ *	scenario where all Rx resources have been indicated and none re-
  *	placed.
  *
  *	V.   Miscellaneous
@@ -954,7 +954,7 @@ static void e100_get_defaults(struct nic *nic)
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
-	/* no interrupt for every tx completion, delay = 256us if not 557*/
+	/* no interrupt for every tx completion, delay = 256us if not 557 */
 	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
@@ -1497,7 +1497,7 @@ static void e100_update_stats(struct nic *nic)
 		&s->complete;
 
 	/* Device's stats reporting may take several microseconds to
-	 * complete, so where always waiting for results of the
+	 * complete, so we're always waiting for results of the
 	 * previous command. */
 
 	if(*complete == cpu_to_le32(cuc_dump_reset_complete)) {
@@ -2858,17 +2858,17 @@ static void e100_shutdown(struct pci_dev *pdev)
 /**
  * e100_io_error_detected - called when PCI error is detected.
  * @pdev: Pointer to PCI device
- * @state: The current pci conneection state
+ * @state: The current pci connection state
  */
 static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	/* Similar to calling e100_down(), but avoids adpater I/O. */
+	/* Similar to calling e100_down(), but avoids adapter I/O. */
 	netdev->stop(netdev);
 
-	/* Detach; put netif into state similar to hotplug unplug. */
+	/* Detach; put netif into a state similar to hotplug unplug. */
 	napi_enable(&nic->napi);
 	netif_device_detach(netdev);
 	pci_disable_device(pdev);

