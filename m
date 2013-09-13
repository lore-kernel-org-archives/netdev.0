From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: fec: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 05:44:38 +0200
Message-ID: <1379043878-6376-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: frank.li@freescale.net, B38611@freescale.com,
	jim_baxter@mentor.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net, fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42848 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750968Ab3IMDop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/freescale/fec_main.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f9aacf5..b2793b9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2199,7 +2199,7 @@ fec_probe(struct platform_device *pdev)
 			goto failed_irq;
 		}
 		ret = devm_request_irq(&pdev->dev, irq, fec_enet_interrupt,
-				       IRQF_DISABLED, pdev->name, ndev);
+				       0, pdev->name, ndev);
 		if (ret)
 			goto failed_irq;
 	}
-- 
1.8.1.2
