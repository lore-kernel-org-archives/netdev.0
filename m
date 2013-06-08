From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 9/9] sh_eth: remove dependencies from Kconfig
Date: Sat, 8 Jun 2013 04:07:13 +0400
Message-ID: <201306080407.14357.sergei.shtylyov@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since dependence on the certain SoCs is no  longer  necessary to compile the
driver, remove the dependency list from its Kconfig entry which is a popular
demand anyway...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/Kconfig |    6 ------
 1 file changed, 6 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/Kconfig
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Kconfig
+++ net-next/drivers/net/ethernet/renesas/Kconfig
@@ -4,12 +4,6 @@
 
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
-	depends on (SUPERH || ARCH_SHMOBILE) && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
-		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
-		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7734 || \
-		 CPU_SUBTYPE_SH7757 || ARCH_R8A7740 || \
-		 ARCH_R8A7778 || ARCH_R8A7779)
 	select CRC32
 	select NET_CORE
 	select MII
