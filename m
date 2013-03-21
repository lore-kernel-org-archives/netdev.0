From: Geoff Levand <geoff@infradead.org>
Subject: [PATCH] net: Fix p3_gelic_net sparse warnings
Date: Thu, 21 Mar 2013 13:35:33 -0700
Message-ID: <1363898133.1075.43.camel@smoke>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39681
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853Ab3CUUfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 16:35:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix these sparse warnings:

  ps3_gelic_net.c: error: marked inline, but without a definition

Signed-off-by: Geoff Levand <geoff@infradead.org>
---

Hi Dave,

Please queue for 3.10.  Thanks.

-Geoff

 drivers/net/ethernet/toshiba/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 445c059..8d03fcb 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -294,7 +294,7 @@ iommu_error:
  * Reset the status of dma descriptors to ready state
  * and re-initialize the hardware chain for later use
  */
-static void gelic_card_reset_chain(struct gelic_card *card,
+static inline void gelic_card_reset_chain(struct gelic_card *card,
 				   struct gelic_descr_chain *chain,
 				   struct gelic_descr *start_descr)
 {
-- 
1.7.9.5
