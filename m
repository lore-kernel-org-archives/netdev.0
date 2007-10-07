From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [BNX2X][PATCH 1/8] add bnx2x to Kconfig and Makefile
Date: Sun, 07 Oct 2007 18:21:32 +0200
Message-ID: <4709078C.7080404@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4423 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbXJGQUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 12:20:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add bnx2x to Kconfig and Makefile

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
drivers/net/Kconfig  |    9 +++++++++
drivers/net/Makefile |    1 +
2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 467532c..fbb69ac 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2630,6 +2630,15 @@ config TEHUTI
help
  Tehuti Networks 10G Ethernet NIC

+config BNX2X
+ tristate "Broadcom NetXtremeII XGb support"
+ depends on PCI
+ help
+   This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
+
+   To compile this driver as a module, choose M here: the module
+   will be called bnx2x.  This is recommended.
+
endif # NETDEV_10000

source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 6220c50..51f3ea7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_STNIC) += stnic.o 8390.o
obj-$(CONFIG_FEALNX) += fealnx.o
obj-$(CONFIG_TIGON3) += tg3.o
obj-$(CONFIG_BNX2) += bnx2.o
+obj-$(CONFIG_BNX2X) += bnx2x.o
spidernet-y += spider_net.o spider_net_ethtool.o
obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
-- 
1.4.2




