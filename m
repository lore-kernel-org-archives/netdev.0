From: Huajun Li <huajun.li.lee@gmail.com>
Subject: [PATCH] usb/rtl8150 : Remove duplicated definitions
Date: Fri, 30 Mar 2012 18:11:05 +0800
Message-ID: <CA+v9cxYHCNTmPagMBMM6quco2EexCobZrF-bpvhKVP40OWjNhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: petkan@users.sourceforge.net, netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55354 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759430Ab2C3KLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 06:11:06 -0400
Received: by wibhj6 with SMTP id hj6so451083wib.1
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 03:11:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist duplicated macro definitions in rtl8150.c, remove them.

Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 drivers/net/usb/rtl8150.c |   26 --------------------------
 1 files changed, 0 insertions(+), 26 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6dda2fe..d363b31 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -85,32 +85,6 @@
 #define INT_CRERR_CNT		0x06
 #define INT_COL_CNT		0x07

-/* Transmit status register errors */
-#define TSR_ECOL		(1<<5)
-#define TSR_LCOL		(1<<4)
-#define TSR_LOSS_CRS		(1<<3)
-#define TSR_JBR			(1<<2)
-#define TSR_ERRORS		(TSR_ECOL | TSR_LCOL | TSR_LOSS_CRS | TSR_JBR)
-/* Receive status register errors */
-#define RSR_CRC			(1<<2)
-#define RSR_FAE			(1<<1)
-#define RSR_ERRORS		(RSR_CRC | RSR_FAE)
-
-/* Media status register definitions */
-#define MSR_DUPLEX		(1<<4)
-#define MSR_SPEED		(1<<3)
-#define MSR_LINK		(1<<2)
-
-/* Interrupt pipe data */
-#define INT_TSR			0x00
-#define INT_RSR			0x01
-#define INT_MSR			0x02
-#define INT_WAKSR		0x03
-#define INT_TXOK_CNT		0x04
-#define INT_RXLOST_CNT		0x05
-#define INT_CRERR_CNT		0x06
-#define INT_COL_CNT		0x07
-

 #define	RTL8150_MTU		1540
 #define	RTL8150_TX_TIMEOUT	(HZ)
-- 
1.7.4.1
