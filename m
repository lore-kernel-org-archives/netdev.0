From: Alban Bedel <albeu@free.fr>
Subject: [PATCH 2/2] 8139too: Allow using the largest possible MTU
Date: Sun, 17 Nov 2013 14:05:24 +0100
Message-ID: <1384693524-20599-2-git-send-email-albeu@free.fr>
References: <1384693524-20599-1-git-send-email-albeu@free.fr>
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dotsec.net ([62.75.224.215]:52077 "EHLO styx.dotsec.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab3KQNjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 08:39:10 -0500
In-Reply-To: <1384693524-20599-1-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver allows MTU up to 1518 bytes which is not enought to run
batman-adv. Simply raise the maximum packet size up to the maximum
allowed by the transmit descriptor, 1792 bytes, giving a maximum MTU
of 1774 bytes.

Signed-off-by: Alban Bedel <albeu@free.fr>
---
 drivers/net/ethernet/realtek/8139too.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 9d5d6d1..7be187a 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -183,7 +183,7 @@ static int debug = -1;
 #define NUM_TX_DESC	4
 
 /* max supported ethernet frame size -- must be at least (dev->mtu+14+4).*/
-#define MAX_ETH_FRAME_SIZE	1536
+#define MAX_ETH_FRAME_SIZE	1792
 
 /* max supported payload size */
 #define MAX_ETH_DATA_SIZE	(MAX_ETH_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN)
-- 
1.8.4.2
