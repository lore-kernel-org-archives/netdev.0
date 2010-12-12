From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 6/6] ethernet: Move Sun Cassini cassini.[ch]
Date: Sun, 12 Dec 2010 04:03:27 -0800
Message-ID: <0ed1dcbd48d5256e63a0cd3b729dac0054ffd520.1292154143.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2528 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab0LLMDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:45 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move Sun Cassini files to ethernet directory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                  |    8 --------
 drivers/net/Makefile                 |    1 -
 drivers/net/ethernet/Kconfig.10-100  |    8 ++++++++
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/{ => ethernet}/cassini.c |    0
 drivers/net/{ => ethernet}/cassini.h |    0
 6 files changed, 9 insertions(+), 9 deletions(-)
 rename drivers/net/{ => ethernet}/cassini.c (100%)
 rename drivers/net/{ => ethernet}/cassini.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fbae645..847dfbe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -581,14 +581,6 @@ config SUNQE
 	  To compile this driver as a module, choose M here: the module
 	  will be called sunqe.
 
-config CASSINI
-	tristate "Sun Cassini support"
-	depends on PCI
-	select CRC32
-	help
-	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
-	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/817-4341-10.pdf>
-
 config SUNVNET
 	tristate "Sun Virtual Network support"
 	depends on SUN_LDOMS
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 129aa08..3972e16 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -60,7 +60,6 @@ obj-$(CONFIG_SUNLANCE) += sunlance.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
 obj-$(CONFIG_MYRI_SBUS) += myri_sbus.o
-obj-$(CONFIG_CASSINI) += cassini.o
 obj-$(CONFIG_SUNVNET) += sunvnet.o
 
 obj-$(CONFIG_MACE) += mace.o
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
index f0430da..2bb39fc 100644
--- a/drivers/net/ethernet/Kconfig.10-100
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -23,6 +23,14 @@ config ETHOC
 	help
 	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
 
+config CASSINI
+	tristate "Sun Cassini support"
+	depends on PCI
+	select CRC32
+	help
+	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
+	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/817-4341-10.pdf>
+
 config HAPPYMEAL
 	tristate "Sun Happy Meal 10/100baseT support"
 	depends on SBUS || PCI
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d7c6304..bba207a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_DNET)		+= dnet.o
 obj-$(CONFIG_ETHOC)		+= ethoc.o
 obj-$(CONFIG_HAPPYMEAL)		+= sunhme.o
 obj-$(CONFIG_SUNGEM)		+= sungem.o sungem_phy.o
+obj-$(CONFIG_CASSINI)		+= cassini.o
diff --git a/drivers/net/cassini.c b/drivers/net/ethernet/cassini.c
similarity index 100%
rename from drivers/net/cassini.c
rename to drivers/net/ethernet/cassini.c
diff --git a/drivers/net/cassini.h b/drivers/net/ethernet/cassini.h
similarity index 100%
rename from drivers/net/cassini.h
rename to drivers/net/ethernet/cassini.h
-- 
1.7.3.3.398.g0b0cd.dirty

