From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/9] ax88796: remove memset of private data
Date: Mon, 21 Feb 2011 14:03:14 +0100
Message-ID: <1298293400-21570-4-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35847 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab1BUND3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:29 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's allocated via alloc_netdev, thus already zeroed.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index c49c3b1..885f04e 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -858,8 +858,6 @@ static int ax_probe(struct platform_device *pdev)
 	ei_local = netdev_priv(dev);
 	ax = to_ax_dev(dev);
 
-	memset(ax, 0, sizeof(struct ax_device));
-
 	spin_lock_init(&ax->mii_lock);
 
 	ax->dev = pdev;
-- 
1.7.2.3

