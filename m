From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [RFC/PATCH] e100 driver didn't support any MII-less PHYs...
Date: Tue, 1 Jan 2008 21:10:31 +0100
Message-ID: <20080101201031.GB14805@rhlx01.hs-esslingen.de>
References: <20071228235118.GA31059@rhlx01.hs-esslingen.de> <477732A5.5020501@intel.com>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bunk@kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:59155 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbYAAUKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 15:10:32 -0500
Content-Disposition: inline
In-Reply-To: <477732A5.5020501@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Dec 29, 2007 at 09:54:45PM -0800, Kok, Auke wrote:
> ok, barely glanced over the patch but it might just be fine. Can you split up this
> patch and send a separate patch for the spelling mistakes? I'll then have some
> quick testing done on the result and do a bit deeper review after newyears.

Part 2, the spelling corrections.

Thanks!

Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.24-rc6/drivers/net/e100.c	2008-01-01 18:53:21.000000000 +0100
+++ linux-2.6.24-rc6/drivers/net/e100.c	2008-01-01 18:53:25.000000000 +0100
@@ -94,7 +94,7 @@
  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
  * 	with 00h.
  *
- *	IV.  Recieve
+ *	IV.  Receive
  *
  *	The Receive Frame Area (RFA) comprises a ring of Receive Frame
  *	Descriptors (RFD) + data buffer, thus forming the simplified mode
@@ -113,7 +113,7 @@
  *	and Rx indication and re-allocation happen in the same context,
  *	therefore no locking is required.  A software-generated interrupt
  *	is generated from the watchdog to recover from a failed allocation
- *	senario where all Rx resources have been indicated and none re-
+ *	scenario where all Rx resources have been indicated and none re-
  *	placed.
  *
  *	V.   Miscellaneous
@@ -958,7 +958,7 @@
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
-	/* no interrupt for every tx completion, delay = 256us if not 557*/
+	/* no interrupt for every tx completion, delay = 256us if not 557 */
 	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
@@ -1550,7 +1550,7 @@
 		&s->complete;
 
 	/* Device's stats reporting may take several microseconds to
-	 * complete, so where always waiting for results of the
+	 * complete, so we're always waiting for results of the
 	 * previous command. */
 
 	if(*complete == le32_to_cpu(cuc_dump_reset_complete)) {
@@ -2884,17 +2884,17 @@
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
