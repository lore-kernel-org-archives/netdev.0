From: Haitao Zhang <minipanda@linuxrobot.org>
Subject: [PATCH] ath9k_htc: Add support for device ID 3346
Date: Sun,  7 Nov 2010 12:50:24 +0800
Message-ID: <1289105424-3597-1-git-send-email-minipanda@linuxrobot.org>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [218.247.216.29] ([218.247.216.29]:58770 "EHLO
	mail.linuxfire.com.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0KGFQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 01:16:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for USB dongle with device ID 3346 from IMC Networks.

Signed-off-by: Haitao Zhang <minipanda@linuxrobot.org>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 6576f68..2f6b1e9 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -35,6 +35,7 @@ static struct usb_device_id ath9k_hif_usb_ids[] = {
 	{ USB_DEVICE(0x07D1, 0x3A10) }, /* Dlink Wireless 150 */
 	{ USB_DEVICE(0x13D3, 0x3327) }, /* Azurewave */
 	{ USB_DEVICE(0x13D3, 0x3328) }, /* Azurewave */
+	{ USB_DEVICE(0x13D3, 0x3346) }, /* IMC Networks */
 	{ USB_DEVICE(0x04CA, 0x4605) }, /* Liteon */
 	{ USB_DEVICE(0x083A, 0xA704) }, /* SMC Networks */
 	{ },
-- 
1.7.0.4

