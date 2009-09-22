From: Fabio Estevam <fabioestevam@yahoo.com>
Subject: [PATCH] fec: Add FEC support for MX25 processor
Date: Mon, 21 Sep 2009 17:41:21 -0700 (PDT)
Message-ID: <123584.91508.qm@web51002.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51002.mail.re2.yahoo.com ([206.190.38.133]:45561 "HELO
	web51002.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751194AbZIVAr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 20:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add FEC support for MX25 processor.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ed5741b..2bea67c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1875,7 +1875,7 @@ config 68360_ENET
 
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27 || ARCH_MX35
+	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27 || ARCH_MX35 || ARCH_MX25
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
-- 
1.6.0.4


      
