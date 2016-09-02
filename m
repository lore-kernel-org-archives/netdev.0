From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 2/3] smsc95xx: Add register define
Date: Fri, 2 Sep 2016 20:34:20 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D409100A1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:41322 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753960AbcIBUeV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:34:21 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add STRAP_STATUS defines.

Signed-off-by: Woojung Huh <Woojung.huh@gmail.com>
---
 drivers/net/usb/smsc95xx.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 526faa0..29a4d9e 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -144,6 +144,14 @@
 
 #define BURST_CAP			(0x38)
 
+#define	STRAP_STATUS			(0x3C)
+#define	STRAP_STATUS_PWR_SEL_		(0x00000020)
+#define	STRAP_STATUS_AMDIX_EN_		(0x00000010)
+#define	STRAP_STATUS_PORT_SWAP_		(0x00000008)
+#define	STRAP_STATUS_EEP_SIZE_		(0x00000004)
+#define	STRAP_STATUS_RMT_WKP_		(0x00000002)
+#define	STRAP_STATUS_EEP_DISABLE_	(0x00000001)
+
 #define GPIO_WAKE			(0x64)
 
 #define INT_EP_CTL			(0x68)
-- 
2.7.4
