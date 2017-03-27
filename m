From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: bfin_mac: Remove unused stats member from struct bfin_mac_local
Date: Mon, 27 Mar 2017 08:55:11 +0200
Message-ID: <20170327065511.27108-1-tklauser@distanz.ch>
Cc: adi-buildroot-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51160 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751406AbdC0Gzf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 02:55:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bfin_mac driver keeps its statistics in net_device->stats, so the
stats member in struct bfin_mac_local is unused. Remove it, as well as
the accompanying comment.

Cc: adi-buildroot-devel@lists.sourceforge.net
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/adi/bfin_mac.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index 8c3b56198e4b..4ad5b9be3f84 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -68,13 +68,6 @@ struct net_dma_desc_tx {
 };
 
 struct bfin_mac_local {
-	/*
-	 * these are things that the kernel wants me to keep, so users
-	 * can find out semi-useless statistics of how well the card is
-	 * performing
-	 */
-	struct net_device_stats stats;
-
 	spinlock_t lock;
 
 	int wol;		/* Wake On Lan */
-- 
2.11.0
