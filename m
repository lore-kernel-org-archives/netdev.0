From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/2] smsc911x: No need to print driver version
Date: Mon, 24 Mar 2014 12:57:26 -0300
Message-ID: <1395676646-14178-2-git-send-email-fabio.estevam@freescale.com>
References: <1395676646-14178-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:6602
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbaCXP5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 11:57:45 -0400
In-Reply-To: <1395676646-14178-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the kernel to print:

"smsc911x: Driver version 2008-10-21" on every boot is not very useful, so
remove the print of the driver version.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index c6a5e89..5f31543 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2380,8 +2380,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	int res_size, irq_flags;
 	int retval;
 
-	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
-
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
 	if (!res)
-- 
1.8.1.2
