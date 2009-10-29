From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/4] sfc: Enable heuristic selection between page and skb
	RX buffers
Date: Thu, 29 Oct 2009 17:21:33 +0000
Message-ID: <1256836893.2827.75.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41264 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756458AbZJ2RVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:21:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can tell whether GRO is being applied, this heuristic is
effective once more.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 9277e9a..a60c718 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -61,7 +61,7 @@
  *   rx_alloc_method = (rx_alloc_level > RX_ALLOC_LEVEL_LRO ?
  *                      RX_ALLOC_METHOD_PAGE : RX_ALLOC_METHOD_SKB)
  */
-static int rx_alloc_method = RX_ALLOC_METHOD_PAGE;
+static int rx_alloc_method = RX_ALLOC_METHOD_AUTO;
 
 #define RX_ALLOC_LEVEL_LRO 0x2000
 #define RX_ALLOC_LEVEL_MAX 0x3000

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

