From: Cord Walter <cord.walter@gmx.de>
Subject: [PATCH] pcnet_cs:fix misuse of the equality operator.
Date: Tue, 03 Feb 2009 11:59:47 +0100
Message-ID: <498823A3.2070506@gmx.de>
References: <20090131071342.2b45cbe8.komurojun-mbn@nifty.com>	<4984DC50.6060204@gmx.de>	<49856D35.7020702@gmx.de> <20090201.014352.138067875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waikiki.ops.eusc.inter.net ([84.23.254.155]:65467 "EHLO
	waikiki.ops.eusc.inter.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751655AbZBCK4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 05:56:49 -0500
Received: from waikiki.ops.eusc.inter.net ([10.155.10.19] helo=localhost)
	by waikiki.ops.eusc.inter.net with esmtpsa (Exim 4.69)
	id 1LUIxL-0002PT-L7
	for netdev@vger.kernel.org; Tue, 03 Feb 2009 11:56:39 +0100
In-Reply-To: <20090201.014352.138067875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:
	fix misuse of the equality operator.


Signed-off-by: Cord Walter <qord@cwalter.net>
Signed-off-by: Komuro <komurojun-mbn@nifty.com>

---

--- linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c.orig	2009-01-31 06:44:03.000000000 +0900
+++ linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c	2009-01-31 06:44:21.000000000 +0900
@@ -586,7 +586,7 @@ static int pcnet_config(struct pcmcia_de
     }

     if ((link->conf.ConfigBase == 0x03c0)
-	&& (link->manf_id == 0x149) && (link->card_id = 0xc1ab)) {
+	&& (link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
 	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
 	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
 	goto failed;


