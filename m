From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH] Fix Micrel KSZ8842 Kconfig description
Date: Fri, 21 Aug 2009 12:20:34 +0200
Message-ID: <20090821102033.GA26577@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Rojfors <richard.rojfors.ext@mocean-labs.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:57192 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521AbZHUKUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 06:20:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when doing a "make oldconfig" recently, non-descriptive item "Micrel KSZ8842"
came up, and when I hit "?" to get more info, all I got was a tight-lipped
"This platform driver is for Micrel KSZ8842 chip.".
I don't need to know whether this is a platform driver or not, I want to
know _what_ the h*ll this thing does, to quickly decide
(and then get on with handling the other 150 upcoming config items)
whether the machine I'm running oldconfig on might actually have this
particular metal-pinned beast soldered somewhere or not.

Thanks,

Andreas Mohr

Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.31-rc6/drivers/net/Kconfig.orig	2009-08-21 12:00:31.000000000 +0200
+++ linux-2.6.31-rc6/drivers/net/Kconfig	2009-08-21 12:09:13.000000000 +0200
@@ -1727,7 +1727,8 @@ config KS8842
 	tristate "Micrel KSZ8842"
 	depends on HAS_IOMEM
 	help
-	  This platform driver is for Micrel KSZ8842 chip.
+	  This platform driver is for Micrel KSZ8842 / KS8842
+	  2-port ethernet switch chip (managed, VLAN, QoS, PCI-based).
 
 config KS8851
        tristate "Micrel KS8851 SPI"
