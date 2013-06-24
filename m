From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/9] sfc: Increase size of RX SKB header area
Date: Mon, 24 Jun 2013 21:13:21 +0100
Message-ID: <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17293 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab3FXUNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:13:25 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

This allows the SKB to hold the headers without reallocation more often.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index b915e09..6efff3d 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -36,7 +36,7 @@
 #define EFX_RECYCLE_RING_SIZE_NOIOMMU (2 * EFX_RX_PREFERRED_BATCH)
 
 /* Size of buffer allocated for skb header area. */
-#define EFX_SKB_HEADERS  64u
+#define EFX_SKB_HEADERS  128u
 
 /* This is the percentage fill level below which new RX descriptors
  * will be added to the RX descriptor ring.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
