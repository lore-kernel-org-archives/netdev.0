From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/2] NET: Add Qlogic ethernet driver for CNA devices
Date: Wed,  6 Jan 2010 03:25:54 -0800
Message-ID: <1262777154-31982-3-git-send-email-amit.salecha@qlogic.com>
References: <1262777154-31982-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45099 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755827Ab0AFLZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 06:25:56 -0500
In-Reply-To: <1262777154-31982-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Separate Ethernet driver for Qlogic CNA devices

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 MAINTAINERS          |    7 +++++++
 drivers/net/Kconfig  |    7 +++++++
 drivers/net/Makefile |    1 +
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 745643b..ed460c5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4452,6 +4452,13 @@ S:	Supported
 F:	Documentation/networking/LICENSE.qla3xxx
 F:	drivers/net/qla3xxx.*
 
+QLOGIC QLCNIC (1/10)Gb ETHERNET DRIVER
+M:	Amit Kumar Salecha <amit.salecha@qlogic.com>
+M:	linux-driver@qlogic.com
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/qlcnic/
+
 QLOGIC QLGE 10Gb ETHERNET DRIVER
 M:	Ron Mercer <ron.mercer@qlogic.com>
 M:	linux-driver@qlogic.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..4fdb20b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2756,6 +2756,13 @@ config BNX2X
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2x.  This is recommended.
 
+config QLCNIC
+	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
+	depends on PCI
+	help
+	  This driver supports QLogic QLE8240 and QLE8242 Converged Ethernet
+	  devices.
+
 config QLGE
 	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ad1346d..a9c4b01 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -148,6 +148,7 @@ ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o
+obj-$(CONFIG_QLCNIC) += qlcnic/
 obj-$(CONFIG_QLGE) += qlge/
 
 obj-$(CONFIG_PPP) += ppp_generic.o
-- 
1.6.0.2

