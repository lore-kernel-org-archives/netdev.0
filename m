From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/15] drivers/net: delete intel 486 panther onboard ethernet support
Date: Mon, 21 Jan 2013 20:46:09 -0500
Message-ID: <1358819182-28032-3-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45316 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab3AVBqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:36 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver was specific to a "professional workstation" line
of products from around 1993 that used the i82596 ethernet chip
as an on-board ethernet solution.

With a 486 processor, and the premium top of the line model maxing
out at a clock speed of 50MHz, we can safely retire this support.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/i825xx/Kconfig  |    8 -
 drivers/net/ethernet/i825xx/Makefile |    1 -
 drivers/net/ethernet/i825xx/lp486e.c | 1337 ----------------------------------
 3 files changed, 1346 deletions(-)
 delete mode 100644 drivers/net/ethernet/i825xx/lp486e.c

diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index c39698a..46edb81 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -93,14 +93,6 @@ config LASI_82596
 	  Say Y here to support the builtin Intel 82596 ethernet controller
 	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
 
-config LP486E
-	tristate "LP486E on board Ethernet"
-	depends on ISA
-	---help---
-	  Say Y here to support the 82596-based on-board Ethernet controller
-	  for the Panther motherboard, which is one of the two shipped in the
-	  Intel Professional Workstation.
-
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
 	depends on MVME16x
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index e5ab9d0..4f01584 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -7,7 +7,6 @@ obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_ELPLUS) += 3c505.o
 obj-$(CONFIG_EL16) += 3c507.o
-obj-$(CONFIG_LP486E) += lp486e.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_ZNET) += znet.o
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
deleted file mode 100644
index 3735bfa..0000000
-- 
1.8.1
