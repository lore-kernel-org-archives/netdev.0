From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] sfc: make local functions static
Date: Sat, 16 Mar 2013 09:57:51 -0700
Message-ID: <20130316095751.33087a2b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39990 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab3CPQ5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 12:57:54 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so5150127pbc.14
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 09:57:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial sparse detected functions that should be static.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/sfc/efx.c	2013-03-14 14:22:58.139958231 -0700
+++ b/drivers/net/ethernet/sfc/efx.c	2013-03-16 09:47:09.417612586 -0700
@@ -2950,8 +2950,8 @@ static const struct dev_pm_ops efx_pm_op
  * At this point MMIO and DMA may be disabled.
  * Stop the software path and request a slot reset.
  */
-pci_ers_result_t efx_io_error_detected(struct pci_dev *pdev,
-				       enum pci_channel_state state)
+static pci_ers_result_t efx_io_error_detected(struct pci_dev *pdev,
+					      enum pci_channel_state state)
 {
 	pci_ers_result_t status = PCI_ERS_RESULT_RECOVERED;
 	struct efx_nic *efx = pci_get_drvdata(pdev);
@@ -2986,7 +2986,7 @@ pci_ers_result_t efx_io_error_detected(s
 }
 
 /* Fake a successfull reset, which will be performed later in efx_io_resume. */
-pci_ers_result_t efx_io_slot_reset(struct pci_dev *pdev)
+static pci_ers_result_t efx_io_slot_reset(struct pci_dev *pdev)
 {
 	struct efx_nic *efx = pci_get_drvdata(pdev);
 	pci_ers_result_t status = PCI_ERS_RESULT_RECOVERED;
--- a/drivers/net/ethernet/sfc/rx.c	2013-03-14 14:22:58.143958179 -0700
+++ b/drivers/net/ethernet/sfc/rx.c	2013-03-16 09:47:24.645415645 -0700
@@ -666,8 +666,8 @@ int efx_probe_rx_queue(struct efx_rx_que
 	return rc;
 }
 
-void efx_init_rx_recycle_ring(struct efx_nic *efx,
-			      struct efx_rx_queue *rx_queue)
+static void efx_init_rx_recycle_ring(struct efx_nic *efx,
+				     struct efx_rx_queue *rx_queue)
 {
 	unsigned int bufs_in_recycle_ring, page_ring_size;
 
