From: Ben Nizette <bn@niasdigital.com>
Subject: [PATCH] macb: Kconfig net device compat fixup
Date: Fri, 17 Apr 2009 17:24:05 +1000
Message-ID: <1239953045.2837.58.camel@linux-51e8.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.icp-qv1-irony-out3.iinet.net.au ([203.59.1.148]:9620
	"EHLO outbound.icp-qv1-irony-out3.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbZDQHYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 03:24:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The macb driver hasn't been updated to use net_device_ops and as such
should select COMPAT_NET_DEV_OPS to avoid build breakage.

Of course really macb should be updated but in the mean time, this at
least avoid randconfig problems.

Signed-off-by: Ben Nizette <bn@niasdigital.com>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9e7baec..dfe1254 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -221,6 +221,7 @@ config MACB
 	tristate "Atmel MACB support"
 	depends on AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263 || ARCH_AT91SAM9G20 || ARCH_AT91CAP9
 	select PHYLIB
+	select COMPAT_NET_DEV_OPS
 	help
 	  The Atmel MACB ethernet interface is found on many AT32 and AT91
 	  parts. Say Y to include support for the MACB chip.


