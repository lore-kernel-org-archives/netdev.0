From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix the AU1000_FIR dependencies
Date: Sat, 15 Apr 2006 16:23:16 +0200
Message-ID: <20060415142316.GH15022@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ralf@linux-mips.org, linux-mips@linux-mips.org,
	Jean-Luc Leger <reiga@dspnet.fr.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:41486 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1030247AbWDOOXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 10:23:18 -0400
To: Samuel.Ortiz@nokia.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patrch fixes the AU1000_FIR dependencies.

Spotted by Jean-Luc Leger.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc1-mm2-full/drivers/net/irda/Kconfig.old	2006-04-15 16:17:36.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/drivers/net/irda/Kconfig	2006-04-15 16:18:06.000000000 +0200
@@ -350,7 +350,7 @@
 
 config AU1000_FIR
 	tristate "Alchemy Au1000 SIR/FIR"
-	depends on MIPS_AU1000 && IRDA
+	depends on SOC_AU1000 && IRDA
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"

