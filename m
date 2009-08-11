From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/6] r8169: phy init for the 8102e
Date: Tue, 11 Aug 2009 07:45:48 +0200
Message-ID: <20090811054548.GG16446@electric-eye.fr.zoreil.com>
References: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60955 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751222AbZHKLwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:52:00 -0400
Content-Disposition: inline
In-Reply-To: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synced with Realtek's 1.013.00 r8101 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 93a87aa..8cd8530 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1729,6 +1729,7 @@ static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
 	mdio_write(ioaddr, 0x1f, 0x0000);
 	mdio_patch(ioaddr, 0x11, 1 << 12);
 	mdio_patch(ioaddr, 0x19, 1 << 13);
+	mdio_patch(ioaddr, 0x10, 1 << 15);
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
-- 
1.6.2.5

