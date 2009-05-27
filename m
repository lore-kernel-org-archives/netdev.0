From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC interrupt may not be shared
Date: Wed, 27 May 2009 02:10:11 -0400
Message-ID: <1243404615-25879-2-git-send-email-vapier@gentoo.org>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32877 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759215AbZE0GKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:10:16 -0400
In-Reply-To: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 9f971ed..1905532 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1108,7 +1108,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	/* now, enable interrupts */
 	/* register irq handler */
 	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED | IRQF_SHARED, "EMAC_RX", ndev);
+			IRQF_DISABLED, "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
-- 
1.6.3.1

