From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] cw1200: add const to hwbus_ops structures
Date: Fri, 23 Jun 2017 17:13:19 +0530
Message-ID: <1498218199-13429-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, pizza@shaftnet.org, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33180 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753492AbdFWLpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 07:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare hwbus_ops structures as const as they are only passed as an
argument to the function cw1200_core_probe. This argument is of type
const. So, make these structures const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/st/cw1200/cw1200_sdio.c | 2 +-
 drivers/net/wireless/st/cw1200/cw1200_spi.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/cw1200_sdio.c b/drivers/net/wireless/st/cw1200/cw1200_sdio.c
index 709f56e..1037ec6 100644
--- a/drivers/net/wireless/st/cw1200/cw1200_sdio.c
+++ b/drivers/net/wireless/st/cw1200/cw1200_sdio.c
@@ -266,7 +266,7 @@ static int cw1200_sdio_pm(struct hwbus_priv *self, bool suspend)
 	return ret;
 }
 
-static struct hwbus_ops cw1200_sdio_hwbus_ops = {
+static const struct hwbus_ops cw1200_sdio_hwbus_ops = {
 	.hwbus_memcpy_fromio	= cw1200_sdio_memcpy_fromio,
 	.hwbus_memcpy_toio	= cw1200_sdio_memcpy_toio,
 	.lock			= cw1200_sdio_lock,
diff --git a/drivers/net/wireless/st/cw1200/cw1200_spi.c b/drivers/net/wireless/st/cw1200/cw1200_spi.c
index 63f95e9..412fb6e4 100644
--- a/drivers/net/wireless/st/cw1200/cw1200_spi.c
+++ b/drivers/net/wireless/st/cw1200/cw1200_spi.c
@@ -352,7 +352,7 @@ static int cw1200_spi_pm(struct hwbus_priv *self, bool suspend)
 	return irq_set_irq_wake(self->func->irq, suspend);
 }
 
-static struct hwbus_ops cw1200_spi_hwbus_ops = {
+static const struct hwbus_ops cw1200_spi_hwbus_ops = {
 	.hwbus_memcpy_fromio	= cw1200_spi_memcpy_fromio,
 	.hwbus_memcpy_toio	= cw1200_spi_memcpy_toio,
 	.lock			= cw1200_spi_lock,
-- 
2.7.4
