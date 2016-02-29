From: Eric Engestrom <eric.engestrom@imgtec.com>
Subject: [PATCH] ethernet/atl1c: remove left over dead code
Date: Mon, 29 Feb 2016 16:40:23 +0000
Message-ID: <1456764023-1123-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Engestrom <eric.engestrom@imgtec.com>
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Machek <pavel@ucw.cz>,
	Ron Angeles <ronangeles@gmail.com>,
	Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:3365 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbcB2QkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 11:40:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Left over from c24588afc536a35c924d014f13b669b20ccf8553
("atl1c: using fixed TXQ configuration for l2cb and l1c")

Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8b5988e..d0084d4 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -65,10 +65,6 @@ static void atl1c_reset_dma_ring(struct atl1c_adapter *adapter);
 static int atl1c_configure(struct atl1c_adapter *adapter);
 static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter);
 
-static const u16 atl1c_pay_load_size[] = {
-	128, 256, 512, 1024, 2048, 4096,
-};
-
 
 static const u32 atl1c_default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 	NETIF_MSG_LINK | NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP;
-- 
2.7.1
