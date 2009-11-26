From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/16] sfc: Move inline comment into kernel-doc
Date: Thu, 26 Nov 2009 02:12:24 +0000
Message-ID: <1259201544.2806.33.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31364 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbZKZCMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:12:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 23e646a..4f4f287 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -55,6 +55,7 @@ static const char *payload_msg =
  * @flush:		Drop all packets in efx_loopback_rx_packet
  * @packet_count:	Number of packets being used in this test
  * @skbs:		An array of skbs transmitted
+ * @offload_csum:	Checksums are being offloaded
  * @rx_good:		RX good packet count
  * @rx_bad:		RX bad packet count
  * @payload:		Payload used in tests
@@ -63,10 +64,7 @@ struct efx_loopback_state {
 	bool flush;
 	int packet_count;
 	struct sk_buff **skbs;
-
-	/* Checksums are being offloaded */
 	bool offload_csum;
-
 	atomic_t rx_good;
 	atomic_t rx_bad;
 	struct efx_loopback_payload payload;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

