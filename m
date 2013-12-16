From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/11] sfc: Changed the statistic name
 emerg_{fetch,wait} to hlb_{fetch,wait}
Date: Mon, 16 Dec 2013 21:34:27 +0000
Message-ID: <1387229667.1799.52.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8663 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3LPVeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:34:31 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>

The original names are unnecessarily alarming.  Head-of-line blocking
is not an emergency.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 8 ++++----
 drivers/net/ethernet/sfc/nic.h  | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b6a0c2133b8a..d352bdc4e53e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -774,8 +774,8 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 	EF10_DMA_STAT(rx_dp_q_disabled_packets, RXDP_Q_DISABLED_PKTS),
 	EF10_DMA_STAT(rx_dp_di_dropped_packets, RXDP_DI_DROPPED_PKTS),
 	EF10_DMA_STAT(rx_dp_streaming_packets, RXDP_STREAMING_PKTS),
-	EF10_DMA_STAT(rx_dp_emerg_fetch, RXDP_EMERGENCY_FETCH_CONDITIONS),
-	EF10_DMA_STAT(rx_dp_emerg_wait, RXDP_EMERGENCY_WAIT_CONDITIONS),
+	EF10_DMA_STAT(rx_dp_hlb_fetch, RXDP_EMERGENCY_FETCH_CONDITIONS),
+	EF10_DMA_STAT(rx_dp_hlb_wait, RXDP_EMERGENCY_WAIT_CONDITIONS),
 };
 
 #define HUNT_COMMON_STAT_MASK ((1ULL << EF10_STAT_tx_bytes) |		\
@@ -844,8 +844,8 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 	(1ULL << EF10_STAT_rx_dp_q_disabled_packets) |			\
 	(1ULL << EF10_STAT_rx_dp_di_dropped_packets) |			\
 	(1ULL << EF10_STAT_rx_dp_streaming_packets) |			\
-	(1ULL << EF10_STAT_rx_dp_emerg_fetch) |				\
-	(1ULL << EF10_STAT_rx_dp_emerg_wait))
+	(1ULL << EF10_STAT_rx_dp_hlb_fetch) |				\
+	(1ULL << EF10_STAT_rx_dp_hlb_wait))
 
 static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 {
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index e25aaf6bda87..170ac6ee3ab2 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -412,8 +412,8 @@ enum {
 	EF10_STAT_rx_dp_q_disabled_packets,
 	EF10_STAT_rx_dp_di_dropped_packets,
 	EF10_STAT_rx_dp_streaming_packets,
-	EF10_STAT_rx_dp_emerg_fetch,
-	EF10_STAT_rx_dp_emerg_wait,
+	EF10_STAT_rx_dp_hlb_fetch,
+	EF10_STAT_rx_dp_hlb_wait,
 	EF10_STAT_COUNT
 };
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
