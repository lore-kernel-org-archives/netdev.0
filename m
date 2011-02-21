From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/9] ax88796: make pointer to platform data const
Date: Mon, 21 Feb 2011 14:03:18 +0100
Message-ID: <1298293400-21570-8-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35856 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077Ab1BUNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:30 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 782d73e..fd289e5 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -89,7 +89,7 @@ struct ax_device {
 	void __iomem *map2;
 	struct resource *mem;
 	struct resource *mem2;
-	struct ax_plat_data *plat;
+	const struct ax_plat_data *plat;
 
 	unsigned char running;
 	unsigned char resume_open;
-- 
1.7.2.3

