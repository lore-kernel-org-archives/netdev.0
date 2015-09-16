From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 6/6] lan78xx: Remove not defined MAC_CR_GMII_EN_ bit
 from MAC_CR.
Date: Wed, 16 Sep 2015 23:41:19 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D55C6B7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:47440 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753067AbbIPXlU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:41:20 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove not defined MAC_CR_GMII_EN_ bit from MAC_CR.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 3 ---
 drivers/net/usb/lan78xx.h | 1 -
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 9102c71..bfac0db 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1909,10 +1909,7 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	} while ((buf & PMT_CTL_PHY_RST_) || !(buf & PMT_CTL_READY_));
 
 	ret = lan78xx_read_reg(dev, MAC_CR, &buf);
-
-	buf |= MAC_CR_GMII_EN_;
 	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
-
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	/* enable PHY interrupts */
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index e0a5a8f..a93fb65 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -549,7 +549,6 @@
 #define LTM_INACTIVE1_TIMER10_		(0x0000FFFF)
 
 #define MAC_CR				(0x100)
-#define MAC_CR_GMII_EN_			(0x00080000)
 #define MAC_CR_EEE_TX_CLK_STOP_EN_	(0x00040000)
 #define MAC_CR_EEE_EN_			(0x00020000)
 #define MAC_CR_EEE_TLAR_EN_		(0x00010000)
-- 
2.1.4
