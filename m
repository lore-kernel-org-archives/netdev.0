From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/4] s2io: make strings at tables const
Date: Fri, 10 Dec 2010 19:40:02 -0600
Message-ID: <1292031604-16628-2-git-send-email-jon.mason@exar.com>
References: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51829 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab0LKBkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 20:40:17 -0500
Received: by gyb11 with SMTP id 11so2143889gyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 17:40:16 -0800 (PST)
In-Reply-To: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put immutable data in read/only section.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |    8 ++++----
 drivers/net/s2io.h |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a6d3eaf..6a87b8c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -91,11 +91,11 @@
 #define DRV_VERSION "2.0.26.27"
 
 /* S2io Driver name & version. */
-static char s2io_driver_name[] = "Neterion";
-static char s2io_driver_version[] = DRV_VERSION;
+static const char s2io_driver_name[] = "Neterion";
+static const char s2io_driver_version[] = DRV_VERSION;
 
-static int rxd_size[2] = {32, 48};
-static int rxd_count[2] = {127, 85};
+static const int rxd_size[2] = {32, 48};
+static const int rxd_count[2] = {127, 85};
 
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 1671443..7d16030 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -360,7 +360,7 @@ struct stat_block {
 #define MAX_TX_DESC    (MAX_AVAILABLE_TXDS)
 
 /* FIFO mappings for all possible number of fifos configured */
-static int fifo_map[][MAX_TX_FIFOS] = {
+static const int fifo_map[][MAX_TX_FIFOS] = {
 	{0, 0, 0, 0, 0, 0, 0, 0},
 	{0, 0, 0, 0, 1, 1, 1, 1},
 	{0, 0, 0, 1, 1, 1, 2, 2},
@@ -371,7 +371,7 @@ static int fifo_map[][MAX_TX_FIFOS] = {
 	{0, 1, 2, 3, 4, 5, 6, 7},
 };
 
-static u16 fifo_selector[MAX_TX_FIFOS] = {0, 1, 3, 3, 7, 7, 7, 7};
+static const u16 fifo_selector[MAX_TX_FIFOS] = {0, 1, 3, 3, 7, 7, 7, 7};
 
 /* Maintains Per FIFO related information. */
 struct tx_fifo_config {
-- 
1.7.0.4

