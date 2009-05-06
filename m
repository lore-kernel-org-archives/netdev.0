From: Wolfgang Denk <wd@denx.de>
Subject: [PATCH 01/12] fs_enet: Use defines to set driver tunables.
Date: Wed,  6 May 2009 22:15:08 +0200
Message-ID: <1241640919-4650-2-git-send-email-wd@denx.de>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
Cc: Piotr Ziecik <kosmo@semihalf.com>, Wolfgang Denk <wd@denx.de>,
	<netdev@vger.kernel.org>, Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:59198 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbZEFUPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:15:23 -0400
In-Reply-To: <1241640919-4650-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Piotr Ziecik <kosmo@semihalf.com>

Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Cc: <netdev@vger.kernel.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a9cbc31..f996a1a 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -46,6 +46,15 @@
 
 #include "fs_enet.h"
 
+/* Driver tunables */
+
+#define ENET_RX_RING_SIZE	32
+#define ENET_TX_RING_SIZE	32
+#define ENET_RX_COPYBREAK	240
+
+#define ENET_USE_NAPI		1
+#define ENET_NAPI_WEIGHT	17
+
 /*************************************************/
 
 MODULE_AUTHOR("Pantelis Antoniou <panto@intracom.gr>");
@@ -1057,11 +1066,11 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		fpi->cp_command = *data;
 	}
 
-	fpi->rx_ring = 32;
-	fpi->tx_ring = 32;
-	fpi->rx_copybreak = 240;
-	fpi->use_napi = 1;
-	fpi->napi_weight = 17;
+	fpi->rx_ring = ENET_RX_RING_SIZE;
+	fpi->tx_ring = ENET_TX_RING_SIZE;
+	fpi->rx_copybreak = ENET_RX_COPYBREAK;
+	fpi->use_napi = ENET_USE_NAPI;
+	fpi->napi_weight = ENET_NAPI_WEIGHT;
 
 	ret = find_phy(ofdev->node, fpi);
 	if (ret)
-- 
1.6.0.6

