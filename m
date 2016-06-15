From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 01/17] sfc: Define macro with EF10 offload feature
Date: Wed, 15 Jun 2016 17:42:26 +0100
Message-ID: <b05c9b55-1d33-0b50-b09f-d06c1fe70dc5@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:27463 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752153AbcFOQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:28 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It is useful to simplify features addition.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1f30912..89c88ca 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4703,6 +4703,12 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 	}
 }
 
+#define EF10_OFFLOAD_FEATURES		\
+	(NETIF_F_IP_CSUM |		\
+	 NETIF_F_IPV6_CSUM |		\
+	 NETIF_F_RXHASH |		\
+	 NETIF_F_NTUPLE)
+
 const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.is_vf = true,
 	.mem_bar = EFX_MEM_VF_BAR,
@@ -4798,8 +4804,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.always_rx_scatter = true,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
-	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
+	.offload_features = EF10_OFFLOAD_FEATURES,
 	.mcdi_max_ver = 2,
 	.max_rx_ip_filters = HUNT_FILTER_TBL_ROWS,
 	.hwtstamp_filters = 1 << HWTSTAMP_FILTER_NONE |
@@ -4919,8 +4924,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.always_rx_scatter = true,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
-	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
+	.offload_features = EF10_OFFLOAD_FEATURES,
 	.mcdi_max_ver = 2,
 	.max_rx_ip_filters = HUNT_FILTER_TBL_ROWS,
 	.hwtstamp_filters = 1 << HWTSTAMP_FILTER_NONE |
