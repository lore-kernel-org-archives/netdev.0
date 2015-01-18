From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 3/7] net: wireless: wcn36xx: use 3680 dxe regs for 3620
Date: Sun, 18 Jan 2015 13:10:54 +0800
Message-ID: <20150118051054.31866.79113.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:51765 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbARFLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:11:00 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Between 3620, 3660 and 3680, only 3660 has a different dxe register

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/dxe.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/dxe.c b/drivers/net/wireless/ath/wcn36xx/dxe.c
index 73f12f1..334f265 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.c
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.c
@@ -46,7 +46,7 @@ static void wcn36xx_dxe_write_register(struct wcn36xx *wcn, int addr, int data)
 
 #define wcn36xx_dxe_write_register_x(wcn, reg, reg_data)		 \
 do {									 \
-	if (wcn->chip_version == WCN36XX_CHIP_3680)			 \
+	if (wcn->chip_version != WCN36XX_CHIP_3660)			 \
 		wcn36xx_dxe_write_register(wcn, reg ## _3680, reg_data); \
 	else								 \
 		wcn36xx_dxe_write_register(wcn, reg ## _3660, reg_data); \
