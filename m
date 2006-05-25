From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/4] [IrDA] *_DONGLE should depend on IRTTY_SIR
Date: Thu, 25 May 2006 06:18:51 +0000
Message-ID: <20060525061851.GA24611@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.pp.htv.fi ([213.243.153.35]:61932 "EHLO smtp2.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932138AbWEXXIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 19:08:46 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a SIR dongle is built in the kernel while IRTTY_SIR is built
as a module, kernel compilation will fail.
Thus, the SIR dongle config should depend on the IRTTY_SIR.

Closes kernel bug# 6512
(http://bugzilla.kernel.org/show_bug.cgi?id=6512)

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>


---

 drivers/net/irda/Kconfig |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

cf17d65eca0463ff3e078fab4db2caac57f5fa46
diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 5e6d007..cff8598 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -33,7 +33,7 @@ config DONGLE
 
 config ESI_DONGLE
 	tristate "ESI JetEye PC dongle"
-	depends on DONGLE && IRDA
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Extended Systems
 	  JetEye PC dongle.  To compile it as a module, choose M here. The ESI
@@ -44,7 +44,7 @@ config ESI_DONGLE
 
 config ACTISYS_DONGLE
 	tristate "ACTiSYS IR-220L and IR220L+ dongle"
-	depends on DONGLE && IRDA
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the ACTiSYS IR-220L and
 	  IR220L+ dongles.  To compile it as a module, choose M here. The
@@ -55,7 +55,7 @@ config ACTISYS_DONGLE
 
 config TEKRAM_DONGLE
 	tristate "Tekram IrMate 210B dongle"
-	depends on DONGLE && IRDA
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Tekram IrMate 210B
 	  dongle.  To compile it as a module, choose M here. The Tekram dongle
@@ -66,7 +66,7 @@ config TEKRAM_DONGLE
 
 config TOIM3232_DONGLE
 	tristate "TOIM3232 IrDa dongle"
-	depends on DONGLE && IRDA
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Vishay/Temic
 	  TOIM3232 and TOIM4232 based dongles.
@@ -74,7 +74,7 @@ config TOIM3232_DONGLE
 
 config LITELINK_DONGLE
 	tristate "Parallax LiteLink dongle"
-	depends on DONGLE && IRDA
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Parallax Litelink
 	  dongle.  To compile it as a module, choose M here.  The Parallax
@@ -85,7 +85,7 @@ config LITELINK_DONGLE
 
 config MA600_DONGLE
 	tristate "Mobile Action MA600 dongle"
-	depends on DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Mobile Action MA600
 	  dongle.  To compile it as a module, choose M here. The MA600 dongle
@@ -98,7 +98,7 @@ config MA600_DONGLE
 
 config GIRBIL_DONGLE
 	tristate "Greenwich GIrBIL dongle"
-	depends on DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Greenwich GIrBIL
 	  dongle.  If you want to compile it as a module, choose M here.
@@ -109,7 +109,7 @@ config GIRBIL_DONGLE
 
 config MCP2120_DONGLE
 	tristate "Microchip MCP2120"
-	depends on DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Microchip MCP2120
 	  dongle.  If you want to compile it as a module, choose M here.
@@ -123,7 +123,7 @@ config MCP2120_DONGLE
 
 config OLD_BELKIN_DONGLE
 	tristate "Old Belkin dongle"
-	depends on DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Adaptec Airport 1000
 	  and 2000 dongles.  If you want to compile it as a module, choose
@@ -132,7 +132,7 @@ config OLD_BELKIN_DONGLE
 
 config ACT200L_DONGLE
 	tristate "ACTiSYS IR-200L dongle"
-	depends on DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the ACTiSYS IR-200L
 	  dongle. If you want to compile it as a module, choose M here.
-- 
1.3.2

