From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 03/12] sky2: document GPHY_CTRL bits
Date: Wed, 29 Aug 2007 12:58:12 -0700
Message-ID: <20070829195842.813275655@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44265 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932111AbXH2UCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:02:22 -0400
Content-Disposition: inline; filename=sky2-gphy-doc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add documentation of GPHY_CTRL register bits even if driver
is not using them (yet).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.h	2007-08-29 11:38:37.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-29 11:40:12.000000000 -0700
@@ -1846,6 +1846,28 @@ enum {
 
 /*	GPHY_CTRL		32 bit	GPHY Control Reg (YUKON only) */
 enum {
+	GPC_TX_PAUSE	= 1<<30, /* Tx pause enabled (ro) */
+	GPC_RX_PAUSE	= 1<<29, /* Rx pause enabled (ro) */
+	GPC_SPEED	= 3<<27, /* PHY speed (ro) */
+	GPC_LINK	= 1<<26, /* Link up (ro) */
+	GPC_DUPLEX	= 1<<25, /* Duplex (ro) */
+	GPC_CLOCK	= 1<<24, /* 125Mhz clock stable (ro) */
+
+	GPC_PDOWN	= 1<<23, /* Internal regulator 2.5 power down */
+	GPC_TSTMODE	= 1<<22, /* Test mode */
+	GPC_REG18	= 1<<21, /* Reg18 Power down */
+	GPC_REG12SEL	= 3<<19, /* Reg12 power setting */
+	GPC_REG18SEL	= 3<<17, /* Reg18 power setting */
+	GPC_SPILOCK	= 1<<16, /* SPI lock (ASF) */
+
+	GPC_LEDMUX	= 3<<14, /* LED Mux */
+	GPC_INTPOL	= 1<<13, /* Interrupt polarity */
+	GPC_DETECT	= 1<<12, /* Energy detect */
+	GPC_1000HD	= 1<<11, /* Enable 1000Mbit HD */
+	GPC_SLAVE	= 1<<10, /* Slave mode */
+	GPC_PAUSE	= 1<<9, /* Pause enable */
+	GPC_LEDCTL	= 3<<6, /* GPHY Leds */
+
 	GPC_RST_CLR	= 1<<1,	/* Clear GPHY Reset */
 	GPC_RST_SET	= 1<<0,	/* Set   GPHY Reset */
 };

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

