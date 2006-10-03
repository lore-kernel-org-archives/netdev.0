From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch 5/6] 2.6.18: sb1250-mac: Interrupt wiring for PHYs
Date: Tue, 3 Oct 2006 16:18:55 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610031602050.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:15887 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964862AbWJCPS5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:18:57 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 This patch defines the wiring for the PHY interrupt lines for the 
supported Broadcom SiByte boards for which documentation is available.

 Please consider.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-mips-2.6.18-20060920-sibyte-phy-irq-15
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/asm-mips/sibyte/sentosa.h linux-mips-2.6.18-20060920/include/asm-mips/sibyte/sentosa.h
--- linux-mips-2.6.18-20060920.macro/include/asm-mips/sibyte/sentosa.h	2006-09-20 20:51:12.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/asm-mips/sibyte/sentosa.h	2006-09-25 21:08:37.000000000 +0000
@@ -37,4 +37,8 @@
 /* GPIOs */
 #define K_GPIO_DBG_LED  0
 
+#ifdef CONFIG_SIBYTE_SENTOSA
+#define K_INT_PHY	K_INT_PCI_INTD
+#endif
+
 #endif /* __ASM_SIBYTE_SENTOSA_H */
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/asm-mips/sibyte/swarm.h linux-mips-2.6.18-20060920/include/asm-mips/sibyte/swarm.h
--- linux-mips-2.6.18-20060920.macro/include/asm-mips/sibyte/swarm.h	2006-09-20 20:51:12.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/asm-mips/sibyte/swarm.h	2006-09-25 21:56:49.000000000 +0000
@@ -67,4 +67,9 @@
 #define K_INT_PC_READY  (K_INT_GPIO_0 + K_GPIO_PC_READY)
 #endif
 
+#ifdef CONFIG_SIBYTE_SWARM
+#define K_GPIO_PHY	2
+#define K_INT_PHY	(K_INT_GPIO_0 + K_GPIO_PHY)
+#endif
+
 #endif /* __ASM_SIBYTE_SWARM_H */
