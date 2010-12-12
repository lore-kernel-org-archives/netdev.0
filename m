From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 5/6] ethernet: Move Sun GEM sungem*.[ch]
Date: Sun, 12 Dec 2010 04:03:26 -0800
Message-ID: <66c71f111ab31ab00ec378ab096966a8a2ed9b37.1292154142.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2523 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab0LLMDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:43 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move Sun GEM files to ethernet directory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                     |    8 --------
 drivers/net/Makefile                    |    1 -
 drivers/net/ethernet/Kconfig.10-100     |    8 ++++++++
 drivers/net/ethernet/Makefile           |    1 +
 drivers/net/{ => ethernet}/sungem.c     |    0
 drivers/net/{ => ethernet}/sungem.h     |    0
 drivers/net/{ => ethernet}/sungem_phy.c |    0
 drivers/net/{ => ethernet}/sungem_phy.h |    0
 8 files changed, 9 insertions(+), 9 deletions(-)
 rename drivers/net/{ => ethernet}/sungem.c (100%)
 rename drivers/net/{ => ethernet}/sungem.h (100%)
 rename drivers/net/{ => ethernet}/sungem_phy.c (100%)
 rename drivers/net/{ => ethernet}/sungem_phy.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 926f090..fbae645 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -581,14 +581,6 @@ config SUNQE
 	  To compile this driver as a module, choose M here: the module
 	  will be called sunqe.
 
-config SUNGEM
-	tristate "Sun GEM support"
-	depends on PCI
-	select CRC32
-	help
-	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
-	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
-
 config CASSINI
 	tristate "Sun Cassini support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8f2c0ee..129aa08 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -60,7 +60,6 @@ obj-$(CONFIG_SUNLANCE) += sunlance.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
 obj-$(CONFIG_MYRI_SBUS) += myri_sbus.o
-obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
 obj-$(CONFIG_CASSINI) += cassini.o
 obj-$(CONFIG_SUNVNET) += sunvnet.o
 
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
index dbb95d3..f0430da 100644
--- a/drivers/net/ethernet/Kconfig.10-100
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -35,3 +35,11 @@ config HAPPYMEAL
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called sunhme.
+
+config SUNGEM
+	tristate "Sun GEM support"
+	depends on PCI
+	select CRC32
+	help
+	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
+	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0daa85c..d7c6304 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_DNET)		+= dnet.o
 obj-$(CONFIG_ETHOC)		+= ethoc.o
 obj-$(CONFIG_HAPPYMEAL)		+= sunhme.o
+obj-$(CONFIG_SUNGEM)		+= sungem.o sungem_phy.o
diff --git a/drivers/net/sungem.c b/drivers/net/ethernet/sungem.c
similarity index 100%
rename from drivers/net/sungem.c
rename to drivers/net/ethernet/sungem.c
diff --git a/drivers/net/sungem.h b/drivers/net/ethernet/sungem.h
similarity index 100%
rename from drivers/net/sungem.h
rename to drivers/net/ethernet/sungem.h
diff --git a/drivers/net/sungem_phy.c b/drivers/net/ethernet/sungem_phy.c
similarity index 100%
rename from drivers/net/sungem_phy.c
rename to drivers/net/ethernet/sungem_phy.c
diff --git a/drivers/net/sungem_phy.h b/drivers/net/ethernet/sungem_phy.h
similarity index 100%
rename from drivers/net/sungem_phy.h
rename to drivers/net/ethernet/sungem_phy.h
-- 
1.7.3.3.398.g0b0cd.dirty

