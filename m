From: Abhishek Shah <abhishek.shah@broadcom.com>
Subject: [PATCH 1/3] net: ethernet: bgmac: Remove unnecessary 'return' from platform_bgmac_idm_write
Date: Fri, 14 Jul 2017 00:34:07 +0530
Message-ID: <1499972649-6200-2-git-send-email-abhishek.shah@broadcom.com>
References: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com,
        Abhishek Shah <abhishek.shah@broadcom.com>
To: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jon Mason <jon.mason@broadcom.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37578 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752778AbdGMTEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 15:04:43 -0400
Received: by mail-wm0-f45.google.com with SMTP id i127so1828286wma.0
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 12:04:38 -0700 (PDT)
In-Reply-To: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return type for idm register write callback should be void as 'writel'
API is used for write operation. However, there no need to have 'return'
in this function.

Signed-off-by: Abhishek Shah <abhishek.shah@broadcom.com>
Reviewed-by: Oza Oza <oza.oza@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 73aca97..1ca75de 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -50,7 +50,7 @@ static u32 platform_bgmac_idm_read(struct bgmac *bgmac, u16 offset)
 
 static void platform_bgmac_idm_write(struct bgmac *bgmac, u16 offset, u32 value)
 {
-	return writel(value, bgmac->plat.idm_base + offset);
+	writel(value, bgmac->plat.idm_base + offset);
 }
 
 static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
-- 
2.7.4
