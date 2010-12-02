From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 14/17] sfc: Update kernel-doc to match earlier
 move of Toeplitz hash key
Date: Thu, 02 Dec 2010 23:47:56 +0000
Message-ID: <1291333676.3259.37.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13124 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358Ab0LBXr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:59 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    1 +
 drivers/net/sfc/nic.h        |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index b7e8fe9..6dd5e6d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -647,6 +647,7 @@ struct efx_filter_state;
  * @n_tx_channels: Number of channels used for TX
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
+ * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
  * @int_error_count: Number of internal errors seen recently
  * @int_error_expire: Time at which error count will be expired
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index f107dc7..eb05869 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -146,7 +146,6 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
  * @fw_build: Firmware build number
  * @mcdi: Management-Controller-to-Driver Interface
  * @wol_filter_id: Wake-on-LAN packet filter id
- * @ipv6_rss_key: Toeplitz hash key for IPv6 RSS
  */
 struct siena_nic_data {
 	u64 fw_version;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

