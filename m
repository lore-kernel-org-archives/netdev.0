From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] net: enable TC35815 for MIPS again
Date: Tue, 07 Feb 2012 09:51:03 +0900 (JST)
Message-ID: <20120207.095103.46315035.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, ralf.roesch@rw-gmbh.de,
	stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defer-dn04.ocn.ad.jp ([125.170.100.158]:59580 "EHLO
	defer-dn04.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530Ab2BGBZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 20:25:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8<----------------------------------------------------------------------
From: Ralf Roesch <ralf.roesch@rw-gmbh.de>
Date: Wed, 16 Nov 2011 09:33:50 +0100
Subject: [PATCH] net: enable TC35815 for MIPS again

TX493[8,9] MIPS SoCs support 2 Ethernet channels of type TC35815
which are connected to the internal PCI controller.
And JMR3927 MIPS board has a TC35815 chip on board.
These dependencies were lost on movement to drivers/net/ethernet/toshiba.

Signed-off-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
CC: stable@vger.kernel.org [3.2+]
---
 drivers/net/ethernet/toshiba/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/Kconfig b/drivers/net/ethernet/toshiba/Kconfig
index 0517647..74acb5c 100644
--- a/drivers/net/ethernet/toshiba/Kconfig
+++ b/drivers/net/ethernet/toshiba/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_TOSHIBA
 	bool "Toshiba devices"
 	default y
-	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB) || PPC_PS3
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB || MIPS) || PPC_PS3
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
-- 
1.7.0.4
