From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 007/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:12:32 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA6@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 7 of 7

Update the help text and description for farsync configuration in the Kernel.
Build farsync and fsflex when the farsync driver is selected.

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---

diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/Kconfig linux-3.10.1_new/drivers/net/wan/Kconfig
--- linux-3.10.1/drivers/net/wan/Kconfig	2013-07-13 19:42:41.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/Kconfig	2013-07-31 14:11:05.792775800 +0100
@@ -248,11 +248,11 @@ config C101
 	  If unsure, say N.
 
 config FARSYNC
-	tristate "FarSync T-Series support"
+	tristate "FarSync T-Series and Flex support"
 	depends on HDLC && PCI
 	---help---
-	  Support for the FarSync T-Series X.21 (and V.35/V.24) cards by
-	  FarSite Communications Ltd.
+	  Support for the FarSync T-Series and FarSync Flex X.21 (and
+          V.35/V.24) ports by FarSite Communications Ltd.
 
 	  Synchronous communication is supported on all ports at speeds up to
 	  8Mb/s (128K on V.24) using synchronous PPP, Cisco HDLC, raw HDLC,
diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/Makefile linux-3.10.1_new/drivers/net/wan/Makefile
--- linux-3.10.1/drivers/net/wan/Makefile	2013-07-13 19:42:41.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/Makefile	2013-07-26 09:14:15.345354002 +0100
@@ -16,7 +16,7 @@ obj-$(CONFIG_HDLC_X25)		+= hdlc_x25.o
 obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	hostess_sv11.o
 obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	sealevel.o
 obj-$(CONFIG_COSA)		+= cosa.o
-obj-$(CONFIG_FARSYNC)		+= farsync.o
+obj-$(CONFIG_FARSYNC)		+= farsync.o fsflex.o
 obj-$(CONFIG_DSCC4)             += dscc4.o
 obj-$(CONFIG_X25_ASY)		+= x25_asy.o

