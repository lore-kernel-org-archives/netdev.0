From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Mark lanstreamer driver as not 64bit clean
Date: Wed, 17 Mar 2004 12:01:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317120117.79cb7b78.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: mikep@linuxtr.net, linux-tr@linuxtr.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It does extremly unsafe things with the PCI DMA API and spews some nasty
warnings on a 64bit compile.

Disable the lanstreamer driver for 64bit hosts for now.

-Andi

diff -u linux/drivers/net/tokenring/Kconfig-o linux/drivers/net/tokenring/Kconfig
--- linux/drivers/net/tokenring/Kconfig-o	1970-01-01 01:12:51.000000000 +0100
+++ linux/drivers/net/tokenring/Kconfig	2004-03-17 11:59:40.000000000 +0100
@@ -54,7 +54,7 @@
 
 config IBMLS
 	tristate "IBM Lanstreamer chipset PCI adapter support"
-	depends on TR && PCI
+	depends on TR && PCI && !64BIT
 	help
 	  This is support for IBM Lanstreamer PCI Token Ring Cards.
 
