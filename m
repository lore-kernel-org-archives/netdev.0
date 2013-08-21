From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] SolutionEngine7724: fix typo in Ether platform data
Date: Thu, 22 Aug 2013 02:18:30 +0400
Message-ID: <201308220218.31183.sergei.shtylyov@cogentembedded.com>
References: <201308220215.16463.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308220215.16463.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit bd61224b1cbec096694e89c4187119c8576fe186 (SolutionEngine7724: fix Ether
support) has a typo in the 'phy_interface' field name of the platform data which
causes build error -- fix it. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 arch/sh/boards/mach-se/7724/setup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/arch/sh/boards/mach-se/7724/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-se/7724/setup.c
+++ net-next/arch/sh/boards/mach-se/7724/setup.c
@@ -377,7 +377,7 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh_eth_plat = {
 	.phy = 0x1f, /* SMSC LAN8187 */
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.phy_interace = PHY_INTERFACE_MODE_MII,
+	.phy_interface = PHY_INTERFACE_MODE_MII,
 };
 
 static struct platform_device sh_eth_device = {
