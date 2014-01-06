From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] bgmac: fix typos
Date: Mon,  6 Jan 2014 23:24:29 +0100
Message-ID: <1389047069-27919-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:39602 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756019AbaAFWYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 17:24:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes some typos found by Sergei.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 5d41f41..7f968a9 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1481,10 +1481,10 @@ static int bgmac_probe(struct bcma_device *core)
 
 		/* Northstar has 4 GMAC cores */
 		for (ns_gmac = 0; ns_gmac < 4; ns_gmac++) {
-			/* As northstar requirement, we have to reset all GAMCs
+			/* As Northstar requirement, we have to reset all GMACs
 			 * before accessing one. bgmac_chip_reset() call
 			 * bcma_core_enable() for this core. Then the other
-			 * three GAMCs didn't reset.  We do it here.
+			 * three GMACs didn't reset.  We do it here.
 			 */
 			ns_core = bcma_find_core_unit(core->bus,
 						      BCMA_CORE_MAC_GBIT,
-- 
1.7.10.4
