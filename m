From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix the AU1000_FIR dependencies
Date: Thu, 29 Jun 2006 17:41:48 +0200
Message-ID: <20060629154148.GA19712@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel.Ortiz@nokia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	linux-mips@linux-mips.org, Jean-Luc Leger <reiga@dspnet.fr.eu.org>
Return-path: <linux-mips-bounce@linux-mips.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This patch fixes the AU1000_FIR dependencies.

Spotted by Jean-Luc Leger.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 15 Apr 2006

--- linux-2.6.17-rc1-mm2-full/drivers/net/irda/Kconfig.old	2006-04-15 16:17:36.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/drivers/net/irda/Kconfig	2006-04-15 16:18:06.000000000 +0200
@@ -350,7 +350,7 @@
 
 config AU1000_FIR
 	tristate "Alchemy Au1000 SIR/FIR"
-	depends on MIPS_AU1000 && IRDA
+	depends on SOC_AU1000 && IRDA
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
