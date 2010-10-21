From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 08/10] can: at91_can: convert readl, writel their __raw pendants
Date: Thu, 21 Oct 2010 13:01:20 +0200
Message-ID: <1287658882-26914-9-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Russell King <rmk@arm.linux.org.uk>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34934 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274Ab0JULB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:28 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Russell King <rmk@arm.linux.org.uk>
---
 drivers/net/can/at91_can.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index ace9c08..12bd615 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -199,13 +199,13 @@ static inline int get_tx_echo_mb(const struct at91_priv *priv)
 
 static inline u32 at91_read(const struct at91_priv *priv, enum at91_reg reg)
 {
-	return readl(priv->reg_base + reg);
+	return __raw_readl(priv->reg_base + reg);
 }
 
 static inline void at91_write(const struct at91_priv *priv, enum at91_reg reg,
 		u32 value)
 {
-	writel(value, priv->reg_base + reg);
+	__raw_writel(value, priv->reg_base + reg);
 }
 
 static inline void set_mb_mode_prio(const struct at91_priv *priv,
-- 
1.7.0.4

