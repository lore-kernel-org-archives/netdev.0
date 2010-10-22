From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/9] drivers/net: typo fix of faild to failed
Date: Thu, 21 Oct 2010 22:17:14 -0700
Message-ID: <246fa5db6273b9f79c3bb27ab2abb22e85fe7b38.1287724261.git.joe@perches.com>
References: <cover.1287724261.git.joe@perches.com>
Cc: Geoff Levand <geoff@infradead.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3464 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab0JVFR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 01:17:26 -0400
In-Reply-To: <cover.1287724261.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ps3_gelic_net.c |    4 ++--
 drivers/net/tulip/pnic2.c   |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 87d6b8f..49f6700 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -642,7 +642,7 @@ static inline void gelic_card_disable_rxdmac(struct gelic_card *card)
 	status = lv1_net_stop_rx_dma(bus_id(card), dev_id(card), 0);
 	if (status)
 		dev_err(ctodev(card),
-			"lv1_net_stop_rx_dma faild, %d\n", status);
+			"lv1_net_stop_rx_dma failed, %d\n", status);
 }
 
 /**
@@ -660,7 +660,7 @@ static inline void gelic_card_disable_txdmac(struct gelic_card *card)
 	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card), 0);
 	if (status)
 		dev_err(ctodev(card),
-			"lv1_net_stop_tx_dma faild, status=%d\n", status);
+			"lv1_net_stop_tx_dma failed, status=%d\n", status);
 }
 
 /**
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index b819766..186d725 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -59,7 +59,7 @@
  * Bit 14:12 - autonegotiation state (write 001 to start autonegotiate)
  * Bit 3     - Autopolarity state
  * Bit 2     - LS10B - link state of 10baseT 0 - good, 1 - failed
- * Bit 1     - LS100B - link state of 100baseT 0 - good, 1- faild
+ * Bit 1     - LS100B - link state of 100baseT 0 - good, 1- failed
  *
  *
  * Data Port Selection Info
-- 
1.7.3.1.g432b3.dirty

