From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 13/13] sfc: Add/remove blank lines to taste
Date: Mon, 3 Feb 2014 23:36:20 +0000
Message-ID: <52F027F4.2020206@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8228 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbaBCXgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:36:23 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Remove trailing blank lines in several files.
Use only one blank line between functions.
Add a blank line as a separator in a few places.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    |    1 -
 drivers/net/ethernet/sfc/falcon.c     |    4 ++--
 drivers/net/ethernet/sfc/farch.c      |    2 --
 drivers/net/ethernet/sfc/net_driver.h |    1 -
 drivers/net/ethernet/sfc/nic.c        |    1 -
 5 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 7d5cb86..89fcaff 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -699,7 +699,6 @@ static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
 	pause->autoneg = !!(efx->wanted_fc & EFX_FC_AUTO);
 }
 
-
 static void efx_ethtool_get_wol(struct net_device *net_dev,
 				struct ethtool_wolinfo *wol)
 {
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 18d6f76..72652f3 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -422,7 +422,6 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 	efx_readd(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
 }
 
-
 static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 {
 	struct efx_nic *efx = dev_id;
@@ -467,6 +466,7 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 		efx_schedule_channel_irq(efx_get_channel(efx, 1));
 	return IRQ_HANDLED;
 }
+
 /**************************************************************************
  *
  * RSS
@@ -1358,6 +1358,7 @@ static void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	case 100:   link_speed = 1; break;
 	default:    link_speed = 0; break;
 	}
+
 	/* MAC_LINK_STATUS controls MAC backpressure but doesn't work
 	 * as advertised.  Disable to ensure packets are not
 	 * indefinitely held and TX queue can be flushed at any point
@@ -2868,4 +2869,3 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.mcdi_max_ver = -1,
 	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
 };
-
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index f72489a..aa1b169 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -311,7 +311,6 @@ static inline void efx_farch_push_tx_desc(struct efx_tx_queue *tx_queue,
  */
 void efx_farch_tx_write(struct efx_tx_queue *tx_queue)
 {
-
 	struct efx_tx_buffer *buffer;
 	efx_qword_t *txd;
 	unsigned write_ptr;
@@ -1609,7 +1608,6 @@ irqreturn_t efx_farch_msi_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-
 /* Setup RSS indirection table.
  * This maps from the hash value of the packet to RXQ
  */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index af2b8c5..8a400a0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1323,7 +1323,6 @@ static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
 	return &rx_queue->buffer[index];
 }
 
-
 /**
  * EFX_MAX_FRAME_LEN - calculate maximum frame length
  *
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 79226b1..32d969e 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -530,4 +530,3 @@ void efx_nic_fix_nodesc_drop_stat(struct efx_nic *efx, u64 *rx_nodesc_drops)
 	efx->rx_nodesc_drops_prev_state = !!(efx->net_dev->flags & IFF_UP);
 	*rx_nodesc_drops -= efx->rx_nodesc_drops_while_down;
 }
-
