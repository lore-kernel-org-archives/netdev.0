From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] net: wireless: p54spi: Fix commenting style
Date: Wed, 29 May 2013 15:31:41 +0530
Message-ID: <1369821701-4867-2-git-send-email-sachin.kamat@linaro.org>
References: <1369821701-4867-1-git-send-email-sachin.kamat@linaro.org>
Cc: netdev@vger.kernel.org, chunkeey@googlemail.com,
	linville@tuxdriver.com, davem@davemloft.net,
	sachin.kamat@linaro.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:44879 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965404Ab3E2KPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 06:15:44 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so8948923pbc.7
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 03:15:44 -0700 (PDT)
In-Reply-To: <1369821701-4867-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the commenting style consistent with networking block comment
style as suggested by checkpatch.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/wireless/p54/p54spi.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 146e653..7fc46f2 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -42,8 +42,7 @@
 
 MODULE_FIRMWARE("3826.arm");
 
-/*
- * gpios should be handled in board files and provided via platform data,
+/* gpios should be handled in board files and provided via platform data,
  * but because it's currently impossible for p54spi to have a header file
  * in include/linux, let's use module paramaters for now
  */
@@ -191,8 +190,7 @@ static int p54spi_request_eeprom(struct ieee80211_hw *dev)
 	const struct firmware *eeprom;
 	int ret;
 
-	/*
-	 * allow users to customize their eeprom.
+	/* allow users to customize their eeprom.
 	 */
 
 	ret = request_firmware(&eeprom, "3826.eeprom", &priv->spi->dev);
@@ -285,8 +283,7 @@ static void p54spi_power_on(struct p54s_priv *priv)
 	gpio_set_value(p54spi_gpio_power, 1);
 	enable_irq(gpio_to_irq(p54spi_gpio_irq));
 
-	/*
-	 * need to wait a while before device can be accessed, the length
+	/* need to wait a while before device can be accessed, the length
 	 * is just a guess
 	 */
 	msleep(10);
@@ -365,7 +362,8 @@ static int p54spi_rx(struct p54s_priv *priv)
 	/* Firmware may insert up to 4 padding bytes after the lmac header,
 	 * but it does not amend the size of SPI data transfer.
 	 * Such packets has correct data size in header, thus referencing
-	 * past the end of allocated skb. Reserve extra 4 bytes for this case */
+	 * past the end of allocated skb. Reserve extra 4 bytes for this case
+	 */
 	skb = dev_alloc_skb(len + 4);
 	if (!skb) {
 		p54spi_sleep(priv);
@@ -383,7 +381,8 @@ static int p54spi_rx(struct p54s_priv *priv)
 	}
 	p54spi_sleep(priv);
 	/* Put additional bytes to compensate for the possible
-	 * alignment-caused truncation */
+	 * alignment-caused truncation
+	 */
 	skb_put(skb, 4);
 
 	if (p54_rx(priv->hw, skb) == 0)
-- 
1.7.9.5
