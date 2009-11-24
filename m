From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/17] sfc: Remove ridiculously paranoid assertions
Date: Tue, 24 Nov 2009 02:01:55 +0000
Message-ID: <1259028115.14645.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34541 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556AbZKXCBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 32cfe40..c407352 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -586,9 +586,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 	/* We now own the SKB */
 	skb = rx_buf->skb;
 	rx_buf->skb = NULL;
-
-	EFX_BUG_ON_PARANOID(rx_buf->page);
-	EFX_BUG_ON_PARANOID(rx_buf->skb);
 	EFX_BUG_ON_PARANOID(!skb);
 
 	/* Set the SKB flags */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

