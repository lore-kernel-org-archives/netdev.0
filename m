From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/1] lan78xx: Change default internal PHY ID to 1
Date: Thu, 27 Aug 2015 18:01:17 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D54C326@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:55828 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751729AbbH0SBS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:01:18 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change default internal PHY ID to 1.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 39364a4..5197a5f 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -57,7 +57,7 @@
 #define DEFAULT_RX_CSUM_ENABLE		(true)
 #define DEFAULT_TSO_CSUM_ENABLE		(true)
 #define DEFAULT_VLAN_FILTER_ENABLE	(true)
-#define INTERNAL_PHY_ID			(2)	/* 2: GMII */
+#define INTERNAL_PHY_ID			(1)
 #define TX_OVERHEAD			(8)
 #define RXW_PADDING			2
 
-- 
2.1.4
