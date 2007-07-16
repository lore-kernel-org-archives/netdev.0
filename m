From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 7/7][ATM]: [idt77252] Rename CONFIG_ATM_IDT77252_SEND_IDLE to not resemble a Kconfig variable
Date: Mon, 16 Jul 2007 12:31:59 -0400
Message-ID: <200707161631.l6GGVxsS009402@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbXGPREp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: [idt77252] Rename CONFIG_ATM_IDT77252_SEND_IDLE to not resemble a Kconfig variable

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit c6023af8babdaefc46d8ac7e3293f4bb87537422
tree f9aaecd241f8263b58caa6929f8b84002227c176
parent 15fa4d7e8fda822d42bc202fe390b52309ee9d86
author Robert P. J. Day <rpjday@mindspring.com> Thu, 12 Jul 2007 14:52:10 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Thu, 12 Jul 2007 14:52:10 -0400

 drivers/atm/idt77252.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 3800bc0..ebd1b66 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -65,7 +65,7 @@ static char const rcsid[] =
 static unsigned int vpibits = 1;
 
 
-#define CONFIG_ATM_IDT77252_SEND_IDLE 1
+#define ATM_IDT77252_SEND_IDLE 1
 
 
 /*
@@ -3404,7 +3404,7 @@ init_card(struct atm_dev *dev)
 	conf =	SAR_CFG_TX_FIFO_SIZE_9 |	/* Use maximum fifo size */
 		SAR_CFG_RXSTQ_SIZE_8k |		/* Receive Status Queue is 8k */
 		SAR_CFG_IDLE_CLP |		/* Set CLP on idle cells */
-#ifndef CONFIG_ATM_IDT77252_SEND_IDLE
+#ifndef ATM_IDT77252_SEND_IDLE
 		SAR_CFG_NO_IDLE |		/* Do not send idle cells */
 #endif
 		0;
@@ -3541,7 +3541,7 @@ init_card(struct atm_dev *dev)
 	printk("%s: Linkrate on ATM line : %u bit/s, %u cell/s.\n",
 	       card->name, linkrate, card->link_pcr);
 
-#ifdef CONFIG_ATM_IDT77252_SEND_IDLE
+#ifdef ATM_IDT77252_SEND_IDLE
 	card->utopia_pcr = card->link_pcr;
 #else
 	card->utopia_pcr = (160000000 / 8 / 54);
