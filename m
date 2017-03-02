From: Maarten Blomme <maartenblomme@gmail.com>
Subject: [PATCH 2/2] spi_ks8995: regs_size incorrect for some devices
Date: Thu,  2 Mar 2017 13:08:49 +0100
Message-ID: <1488456529-30128-1-git-send-email-maartenblomme@gmail.com>
Cc: netdev@vger.kernel.org, "Blomme, Maarten" <Maarten.Blomme@flir.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34053 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdCBMHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 07:07:40 -0500
Received: by mail-wm0-f65.google.com with SMTP id m70so12085245wma.1
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 04:05:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Blomme, Maarten" <Maarten.Blomme@flir.com>

Signed-off-by: Maarten Blomme <Maarten.Blomme@flir.com>
---
 drivers/net/phy/spi_ks8995.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index aa7209d..1e2d4f1 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -491,8 +491,8 @@ static int ks8995_probe(struct spi_device *spi)
 	if (err)
 		return err;
 
-	ks->regs_attr.size = ks->chip->regs_size;
 	memcpy(&ks->regs_attr, &ks8995_registers_attr, sizeof(ks->regs_attr));
+	ks->regs_attr.size = ks->chip->regs_size;
 
 	err = ks8995_reset(ks);
 	if (err)
-- 
2.7.4
