From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] fec_ptp: Use a more standard logging
Date: Mon, 27 May 2013 16:10:26 -0300
Message-ID: <1369681826-5421-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:8051 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754170Ab3E0TKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 15:10:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is preferable to use netdev_err when possible.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 25fc960..588dd91 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -17,8 +17,6 @@
  * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -380,6 +378,6 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
 	if (IS_ERR(fep->ptp_clock)) {
 		fep->ptp_clock = NULL;
-		pr_err("ptp_clock_register failed\n");
+		netdev_err(ndev, "ptp_clock_register failed\n");
 	}
 }
-- 
1.8.1.2
