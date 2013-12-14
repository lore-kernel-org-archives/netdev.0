From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/15] sfc: Remove kernel-doc for efx_ptp_data
 fields not present in this version
Date: Sat, 14 Dec 2013 23:01:58 +0000
Message-ID: <1387062118.12172.62.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17290 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:02:02 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 96008202cbc3..be7ed4e1c96c 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -248,21 +248,6 @@ struct efx_ptp_timeset {
  * @nic_ts_enabled: Flag indicating if NIC generated TS events are handled
  * @txbuf: Buffer for use when transmitting (PTP) packets to MC (avoids
  *         allocations in main data path).
- * @debug_ptp_dir: PTP debugfs directory
- * @missed_rx_sync: Number of packets received without syncrhonisation.
- * @good_syncs: Number of successful synchronisations.
- * @no_time_syncs: Number of synchronisations with no good times.
- * @bad_sync_durations: Number of synchronisations with bad durations.
- * @bad_syncs: Number of failed synchronisations.
- * @last_sync_time: Number of nanoseconds for last synchronisation.
- * @sync_timeouts: Number of synchronisation timeouts
- * @fast_syncs: Number of synchronisations requiring short delay
- * @min_sync_delta: Minimum time between event and synchronisation
- * @max_sync_delta: Maximum time between event and synchronisation
- * @average_sync_delta: Average time between event and synchronisation.
- *                      Modified moving average.
- * @last_sync_delta: Last time between event and synchronisation
- * @mc_stats: Context value for MC statistics
  * @timeset: Last set of synchronisation statistics.
  */
 struct efx_ptp_data {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
