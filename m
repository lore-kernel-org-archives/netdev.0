From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/15] drivers/net: delete Racal Interlan ISA ni52 (i825xx) driver
Date: Mon, 21 Jan 2013 20:46:15 -0500
Message-ID: <1358819182-28032-9-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45348 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab3AVBqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:39 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the other drivers that were in the ISA i825xx family, the ni52
was rather rare, not widely used, and hence perhaps not as reliable
as the more mainstream ISA drivers that were heavily used.  Given
that, it is chosen for retirement at this time as well.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                  |    4 -
 drivers/net/ethernet/i825xx/Kconfig  |   11 -
 drivers/net/ethernet/i825xx/Makefile |    1 -
 drivers/net/ethernet/i825xx/ni52.c   | 1346 ----------------------------------
 drivers/net/ethernet/i825xx/ni52.h   |  310 --------
 5 files changed, 1672 deletions(-)
 delete mode 100644 drivers/net/ethernet/i825xx/ni52.c
 delete mode 100644 drivers/net/ethernet/i825xx/ni52.h

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 726b17b..b69dac1 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -51,7 +51,6 @@ extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
-extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
 extern struct net_device *seeq8005_probe(int unit);
@@ -157,9 +156,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_NI5010
 	{ni5010_probe, 0},
 #endif
-#ifdef CONFIG_NI52
-	{ni52_probe, 0},
-#endif
 #ifdef CONFIG_NI65
 	{ni65_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index c3cfa57..955d929 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -52,17 +52,6 @@ config MVME16x_NET
 	  driver for this chip in your kernel.
 	  To compile this driver as a module, choose M here.
 
-config NI52
-	tristate "NI5210 support"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni52.
-
 config SNI_82596
 	tristate "SNI RM ethernet"
 	depends on SNI_RM
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index df9e2ec..8c8dcd2 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -3,7 +3,6 @@
 #
 
 obj-$(CONFIG_ARM_ETHER1) += ether1.o
-obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
diff --git a/drivers/net/ethernet/i825xx/ni52.c b/drivers/net/ethernet/i825xx/ni52.c
deleted file mode 100644
index 272976e..0000000
diff --git a/drivers/net/ethernet/i825xx/ni52.h b/drivers/net/ethernet/i825xx/ni52.h
deleted file mode 100644
index 0a03b28..0000000
-- 
1.8.1
