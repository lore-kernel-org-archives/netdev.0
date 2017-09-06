From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 4/4] lan78xx: Use default value loaded from EEPROM/OTP
 when resetting the chip
Date: Wed, 6 Sep 2017 10:52:07 +0000
Message-ID: <CE371C1263339941885964188A0225FA3333A1@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:65533 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753217AbdIFKwQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:52:16 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Use default value loaded from EEPROM/OTP when resetting
 the chip

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index e04ec23..84491e7 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2497,7 +2497,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	/* LAN7801 only has RGMII mode */
 	if (dev->chipid == ID_REV_CHIP_ID_7801_)
 		buf &= ~MAC_CR_GMII_EN_;
-	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-- 
1.9.1
