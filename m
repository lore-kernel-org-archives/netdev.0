From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/15] drivers/net: delete old DEC depca ISA drivers support.
Date: Mon, 21 Jan 2013 20:46:20 -0500
Message-ID: <1358819182-28032-14-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45374 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab3AVBqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:42 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are old ISA 10Mbit cards from the 1st 1/2 of the 1990s and
required manual jumper settings in order to configure them.  Here
we remove them on the premise that they are no longer used in any
modern 3.9+ kernels.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/00-INDEX  |    2 -
 Documentation/networking/depca.txt |   92 --
 drivers/net/ethernet/amd/Kconfig   |   13 -
 drivers/net/ethernet/amd/Makefile  |    1 -
 drivers/net/ethernet/amd/depca.c   | 1910 ------------------------------------
 drivers/net/ethernet/amd/depca.h   |  183 ----
 6 files changed, 2201 deletions(-)
 delete mode 100644 Documentation/networking/depca.txt
 delete mode 100644 drivers/net/ethernet/amd/depca.c
 delete mode 100644 drivers/net/ethernet/amd/depca.h

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 1abfff2..6ec1d6f 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -52,8 +52,6 @@ de4x5.txt
 	- the Digital EtherWORKS DE4?? and DE5?? PCI Ethernet driver
 decnet.txt
 	- info on using the DECnet networking layer in Linux.
-depca.txt
-	- the Digital DEPCA/EtherWORKS DE1?? and DE2?? LANCE Ethernet driver
 dl2k.txt
 	- README for D-Link DL2000-based Gigabit Ethernet Adapters (dl2k.ko).
 dm9000.txt
diff --git a/Documentation/networking/depca.txt b/Documentation/networking/depca.txt
deleted file mode 100644
index 24c6b26..0000000
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 3046133..13d74aa 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -105,19 +105,6 @@ config DECLANCE
 	  DEC (now Compaq) based on the AMD LANCE chipset, including the
 	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
 
-config DEPCA
-	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
-	depends on (ISA || EISA)
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:drivers/net/ethernet/amd/depca.c>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called depca.
-
 config HPLANCE
 	bool "HP on-board LANCE support"
 	depends on DIO
diff --git a/drivers/net/ethernet/amd/Makefile b/drivers/net/ethernet/amd/Makefile
index 175caa5..cdd4301 100644
--- a/drivers/net/ethernet/amd/Makefile
+++ b/drivers/net/ethernet/amd/Makefile
@@ -8,7 +8,6 @@ obj-$(CONFIG_ARM_AM79C961A) += am79c961a.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_DECLANCE) += declance.o
-obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
deleted file mode 100644
index 34a4853..0000000
diff --git a/drivers/net/ethernet/amd/depca.h b/drivers/net/ethernet/amd/depca.h
deleted file mode 100644
index cdcfe42..0000000
-- 
1.8.1
