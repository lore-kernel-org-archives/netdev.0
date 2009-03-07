From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/2] gigaset: Kconfig cleanup
Date: Sat,  7 Mar 2009 23:11:02 +0100 (CET)
Message-ID: <20090307-patch-02.tilman@imap.cc>
References: <20090307-patch-00.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756896AbZCGWLt@vger.kernel.org>
In-Reply-To: <20090307-patch-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Streamline dependencies and remove some obsolete or redundant comments
in the Gigaset ISDN driver's Kconfig file. In particular, remove the
strong warning against the GIGASET_UNDOCREQ option, as in seven years
of existence, the code in question has never been reported to cause
any harm.

Impact: Kconfig cleanup, no functional change

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/Kconfig |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index 0017e50..9ca889a 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -1,5 +1,5 @@
 menuconfig ISDN_DRV_GIGASET
-	tristate "Siemens Gigaset support (isdn)"
+	tristate "Siemens Gigaset support"
 	select CRC_CCITT
 	select BITREVERSE
 	help
@@ -11,11 +11,11 @@ menuconfig ISDN_DRV_GIGASET
 	  one of the connection specific parts that follow.
 	  This will build a module called "gigaset".
 
-if ISDN_DRV_GIGASET!=n
+if ISDN_DRV_GIGASET
 
 config GIGASET_BASE
 	tristate "Gigaset base station support"
-	depends on ISDN_DRV_GIGASET && USB
+	depends on USB
 	help
 	  Say M here if you want to use the USB interface of the Gigaset
 	  base for connection to your system.
@@ -23,7 +23,7 @@ config GIGASET_BASE
 
 config GIGASET_M105
 	tristate "Gigaset M105 support"
-	depends on ISDN_DRV_GIGASET && USB
+	depends on USB
 	help
 	  Say M here if you want to connect to the Gigaset base via DECT
 	  using a Gigaset M105 (Sinus 45 Data 2) USB DECT device.
@@ -31,7 +31,6 @@ config GIGASET_M105
 
 config GIGASET_M101
 	tristate "Gigaset M101 support"
-	depends on ISDN_DRV_GIGASET
 	help
 	  Say M here if you want to connect to the Gigaset base via DECT
 	  using a Gigaset M101 (Sinus 45 Data 1) RS232 DECT device.
@@ -48,7 +47,6 @@ config GIGASET_UNDOCREQ
 	help
 	  This enables support for USB requests we only know from
 	  reverse engineering (currently M105 only). If you need
-	  features like configuration mode of M105, say yes. If you
-	  care about your device, say no.
+	  features like configuration mode of M105, say yes.
 
-endif # ISDN_DRV_GIGASET != n
+endif # ISDN_DRV_GIGASET
-- 
1.5.4.7.gd8534-dirty
