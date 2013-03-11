From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/22] sfc: Document current usage of
 efx_rx_buffer::len and efx_nic::rx_buffer_len
Date: Mon, 11 Mar 2013 19:55:53 +0000
Message-ID: <1363031753.2608.49.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16782 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab3CKTz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:55:56 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9e90081..f74411f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -209,7 +209,8 @@ struct efx_tx_queue {
  * @page: The associated page buffer.
  *	Will be %NULL if the buffer slot is currently free.
  * @page_offset: Offset within page
- * @len: Buffer length, in bytes.
+ * @len: If pending: length for DMA descriptor.
+ *	If completed: received length, excluding hash prefix.
  * @flags: Flags for buffer and packet state.
  */
 struct efx_rx_buffer {
@@ -668,7 +669,8 @@ struct vfdi_status;
  * @n_channels: Number of channels in use
  * @n_rx_channels: Number of channels used for RX (= number of RX queues)
  * @n_tx_channels: Number of channels used for TX
- * @rx_buffer_len: RX buffer length
+ * @rx_buffer_len: RX buffer length, including start alignment but excluding
+ *	any metadata
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
