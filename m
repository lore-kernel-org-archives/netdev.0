From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: [patch 1/3 v2]  Add tsi108 On Chip Ethernet device driver support
Date: 21 Sep 2006 12:04:36 +0800
Message-ID: <1158811476.10823.43.camel@localhost.localdomain>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
	 <1158051327.14448.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:30180 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1751199AbWIUEEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 00:04:47 -0400
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <1158051327.14448.93.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Tundra Semiconductor Corporation (Tundra) Tsi108/9 is a host bridge
for PowerPC processors that offers numerous system interconnect options
for embedded application designers . The Tsi108/9 can interconnect 60x
or MPX processors to PCI/X peripherals, DDR2-400 memory, Gigabit
Ethernet, and Flash.
Tsi108/109 is used on powerpc/mpc7448hpc2 platform.
The following patch provides Tsi108/9 on chip Ethernet chip driver
config and Makefile.


Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
Signed-off-by: Roy Zang <tie-fei.zang@freescale.com> 


--
 drivers/net/Kconfig  |    8 ++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a2bd811..eb17060 100644
-- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2221,6 +2221,14 @@ config SPIDER_NET
 	  This driver supports the Gigabit Ethernet chips present on the
 	  Cell Processor-Based Blades from IBM.
 
+config TSI108_ETH
+	   tristate "Tundra TSI108 gigabit Ethernet support"
+	   depends on TSI108_BRIDGE
+	   help
+	     This driver supports Tundra TSI108 gigabit Ethernet ports.
+	     To compile this driver as a module, choose M here: the module
+	     will be called tsi108_eth.
+
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx || PPC_86xx
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8427bf9..da199e7 100644
-- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -112,6 +112,7 @@ obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
 
+obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o slhc.o
-- 
1.4.0

