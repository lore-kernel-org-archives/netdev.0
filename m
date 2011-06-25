From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: TC35815: Only build driver on Toshiba eval boards.
Date: Sat, 25 Jun 2011 17:54:09 +0100
Message-ID: <20110625165409.GA1760@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:53471 "EHLO duck.linux-mips.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751617Ab1FYQyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 12:54:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's the only place where the TC35815 is known to be used.

  Ralf

 drivers/net/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index be25e92..2b4ebfb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1516,7 +1516,8 @@ config CS89x0_NONISA_IRQ
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
-	depends on NET_PCI && PCI && MIPS
+	depends on NET_PCI && PCI && MACH_TXX9
+	default y
 	select PHYLIB
 
 config E100
