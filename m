From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/05] r8169: revert
	7da97ec96a0934319c7fbedd3d38baf533e20640 (bis repetita)
Date: Fri, 9 Nov 2007 00:11:20 +0100
Message-ID: <20071108231119.GE15968@electric-eye.fr.zoreil.com>
References: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59458 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932238AbXKHXyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 18:54:25 -0500
Content-Disposition: inline
In-Reply-To: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RTL_GIGA_MAC_VER_17 breaks as well.

Signed-off-by: Mark Lord <mlord@pobox.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a37cf82..f9ba2e4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1247,16 +1247,6 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
-static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
-{
-	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
-		{ 0x10, 0xf41b },
-		{ 0x1f, 0x0000 }
-	};
-
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
-}
 
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 {
@@ -1326,12 +1316,6 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
-	case RTL_GIGA_MAC_VER_11:
-	case RTL_GIGA_MAC_VER_12:
-		break;
-	case RTL_GIGA_MAC_VER_17:
-		rtl8168b_hw_phy_config(ioaddr);
-		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
-- 
1.5.3.3

