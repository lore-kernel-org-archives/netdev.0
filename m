From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/5] r8169: phy program update
Date: Mon, 4 Dec 2006 00:59:54 +0100
Message-ID: <20061203235954.GD3625@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061203235813.GC3625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33926 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1760133AbWLDAAh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 19:00:37 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061203235813.GC3625@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is commented out in Realtek's driver as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7438049..0b57050 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1286,11 +1286,6 @@ static void rtl8169_hw_phy_config(struct
 	/* Shazam ! */
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
-		mdio_write(ioaddr, 31, 0x0001);
-		mdio_write(ioaddr,  9, 0x273a);
-		mdio_write(ioaddr, 14, 0x7bfb);
-		mdio_write(ioaddr, 27, 0x841e);
-
 		mdio_write(ioaddr, 31, 0x0002);
 		mdio_write(ioaddr,  1, 0x90d0);
 		mdio_write(ioaddr, 31, 0x0000);
-- 
1.4.2.3

