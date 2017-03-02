From: Maarten Blomme <maartenblomme@gmail.com>
Subject: [PATCH 1/2] spi_ks8995: fix "BUG: key accdaa28 not in .data!"
Date: Thu,  2 Mar 2017 13:08:36 +0100
Message-ID: <1488456516-30075-1-git-send-email-maartenblomme@gmail.com>
Cc: netdev@vger.kernel.org, "Blomme, Maarten" <Maarten.Blomme@flir.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33971 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750986AbdCBMHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 07:07:40 -0500
Received: by mail-wm0-f65.google.com with SMTP id m70so12084386wma.1
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 04:05:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Blomme, Maarten" <Maarten.Blomme@flir.com>

Signed-off-by: Maarten Blomme <Maarten.Blomme@flir.com>
---
 drivers/net/phy/spi_ks8995.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 93ffedf..aa7209d 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -498,6 +498,7 @@ static int ks8995_probe(struct spi_device *spi)
 	if (err)
 		return err;
 
+	sysfs_attr_init(&ks->regs_attr.attr);
 	err = sysfs_create_bin_file(&spi->dev.kobj, &ks->regs_attr);
 	if (err) {
 		dev_err(&spi->dev, "unable to create sysfs file, err=%d\n",
-- 
2.7.4
