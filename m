From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: pch_gbe depends on x86_32
Date: Fri, 16 May 2014 11:29:04 +0200
Message-ID: <20140516112904.7072da0f@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35537 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522AbaEPJ3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 05:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pch_gbe driver is for a companion chip to the Intel Atom E600
series processors. These are 32-bit x86 processors so the driver is
only needed on X86_32.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-3.15-rc5.orig/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig	2014-03-31 05:40:15.000000000 +0200
+++ linux-3.15-rc5/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig	2014-05-16 11:20:28.453261606 +0200
@@ -4,7 +4,7 @@
 
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-	depends on PCI && (X86 || COMPILE_TEST)
+	depends on PCI && (X86_32 || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---


-- 
Jean Delvare
SUSE L3 Support
