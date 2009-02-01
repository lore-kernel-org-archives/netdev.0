From: Cord Walter <cord.walter@gmx.de>
Subject: Re: pcnet_cs: fix misuse of the equality operator. - 3rd try...
Date: Sun, 01 Feb 2009 11:38:07 +0100
Message-ID: <49857B8F.9000406@gmx.de>
References: <20090131071342.2b45cbe8.komurojun-mbn@nifty.com>	<4984DC50.6060204@gmx.de>	<49856D35.7020702@gmx.de> <20090201.014352.138067875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waikiki.ops.eusc.inter.net ([84.23.254.155]:61635 "EHLO
	waikiki.ops.eusc.inter.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752618AbZBAKiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 05:38:16 -0500
Received: from myip-n72-220.de.inter.net ([213.73.72.220] helo=rei.cwalter.net)
	by waikiki.ops.eusc.inter.net with esmtp (Exim 4.69)
	id 1LTZiO-0008UT-Mo
	for netdev@vger.kernel.org; Sun, 01 Feb 2009 11:38:12 +0100
Received: from [10.42.42.2] (nene.cwalter.net [10.42.42.2])
	by rei.cwalter.net (Postfix) with ESMTP id 48C201BE5F
	for <netdev@vger.kernel.org>; Sun,  1 Feb 2009 11:38:12 +0100 (CET)
In-Reply-To: <20090201.014352.138067875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] pcnet_cs:fix misuse of the equality operator.


pcnet_cs:
	fix misuse of the equality operator.


Signed-off-by: Cord Walter <qord@cwalter.net>
Signed-off-by: Komuro <komurojun-mbn@nifty.com>

---

--- linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c.orig	2009-01-31
06:44:03.000000000 +0900
+++ linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c	2009-01-31
06:44:21.000000000 +0900
@@ -586,7 +586,7 @@ static int pcnet_config(struct pcmcia_de
     }

     if ((link->conf.ConfigBase == 0x03c0)
-	&& (link->manf_id == 0x149) && (link->card_id = 0xc1ab)) {
+	&& (link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
 	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
 	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
 	goto failed;

