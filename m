From: Fabio Estevam <fabioestevam@yahoo.com>
Subject: [PATCH] fec: Add FEC support for MX35 processor
Date: Wed, 27 May 2009 06:41:39 -0700 (PDT)
Message-ID: <437683.77353.qm@web51007.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51007.mail.re2.yahoo.com ([206.190.38.138]:27305 "HELO
	web51007.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1762232AbZE0NsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 09:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add FEC support for MX35 processor.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
Acked-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..84a94ec 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1858,8 +1858,8 @@ config 68360_ENET
 	  the Motorola 68360 processor.
 
 config FEC
-	bool "FEC ethernet controller (of ColdFire CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27
+	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	depends on M523x || M527x || M5272 || M528x || M520x || M532x || MACH_MX27 || ARCH_MX35
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
-- 
1.5.4.5


      
