From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] CONFIG_IA64_SGI_SN1 is gone
Date: Mon, 1 Sep 2003 11:21:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901092100.GA31136@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

and the IOC3 driver would only work with SN0/Mips anyway.


--- 1.40/drivers/net/Kconfig	Mon Aug 18 23:59:59 2003
+++ edited/drivers/net/Kconfig	Mon Sep  1 10:05:48 2003
@@ -502,7 +502,7 @@
 
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
-	depends on NET_ETHERNET && (IA64_SGI_SN1 || SGI_IP27)
+	depends on NET_ETHERNET && SGI_IP27
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
