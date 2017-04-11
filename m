From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 10/10] ftgmac100: Set default ring sizes to 128 entries
Date: Tue, 11 Apr 2017 11:04:36 +1000
Message-ID: <20170411010436.23290-11-benh@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51466 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752109AbdDKBHA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:07:00 -0400
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't seen any improvement above that size on the machines
I've tested with.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2f0b73b..af11e2b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -45,8 +45,8 @@
 #define MIN_TX_QUEUE_ENTRIES	32
 
 /* Defaults */
-#define DEF_RX_QUEUE_ENTRIES	256
-#define DEF_TX_QUEUE_ENTRIES	512
+#define DEF_RX_QUEUE_ENTRIES	128
+#define DEF_TX_QUEUE_ENTRIES	128
 
 #define MAX_PKT_SIZE		1536
 #define RX_BUF_SIZE		MAX_PKT_SIZE	/* must be smaller than 0x3fff */
-- 
2.9.3
