From: <Nisar.Sayed@microchip.com>
Subject: [PATCH 3/3] lan78xx: Use default value loaded from EEPROM/OTP when
 resetting
Date: Thu, 7 Sep 2017 07:11:50 +0000
Message-ID: <CE371C1263339941885964188A0225FA333A8D@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:4700 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752021AbdIGHMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 03:12:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Use default value loaded from EEPROM/OTP when resetting

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 94ef943..8fd7c2f 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2452,7 +2452,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	/* LAN7801 only has RGMII mode */
 	if (dev->chipid == ID_REV_CHIP_ID_7801_)
 		buf &= ~MAC_CR_GMII_EN_;
-	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-- 
1.9.1
