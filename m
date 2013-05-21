From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/2] fec: Use DIV_ROUND_UP macro
Date: Tue, 21 May 2013 12:44:26 -0300
Message-ID: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:13513
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370Ab3EUPq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 11:46:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the standard DIV_ROUND_UP macro in order to provide better readability.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e277860..706e224 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -242,7 +242,7 @@ static void *swap_buffer(void *bufaddr, int len)
 	int i;
 	unsigned int *buf = bufaddr;
 
-	for (i = 0; i < (len + 3) / 4; i++, buf++)
+	for (i = 0; i < DIV_ROUND_UP(len, 4); i++, buf++)
 		*buf = cpu_to_be32(*buf);
 
 	return bufaddr;
-- 
1.8.1.2
