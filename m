From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] 3c509: Add missing EISA IDs
Date: Sun, 31 May 2009 00:40:31 +0100 (BST)
Message-ID: <alpine.LFD.1.10.0905310021070.15490@ftp.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.58.128.207] ([213.58.128.207]:43225 "EHLO
	ftp.linux-mips.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbZE3Xkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 19:40:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Several EISA device IDs for 3c509 family network cards are missing from 
the driver, making the cards unusable in their EISA mode.  Here's a fix to 
add them based on the EISA configuration files distributed by 3Com and our 
eisa.ids database.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Successfully tested with a 3c509-Combo network card:

EISA: Probing bus 0 at eisa.0
EISA: Mainboard AEI0401 detected.
EISA: slot 6 : NPI0303 detected.
EISA: slot 8 : TCM5094 detected.
eth0: 3c5x9 found at 0x8000, 10baseT port, address 00:a0:24:b6:8b:db, IRQ 11.
3c509.c:1.20 04Feb2008 becker@scyld.com
EISA: Detected 2 cards.

 Please apply.

  Maciej

patch-mips-2.6.27-rc8-20081004-3c509-eisa-0
Index: linux-mips-2.6.27-rc8-20081004-dolch/drivers/net/3c509.c
===================================================================
--- linux-mips-2.6.27-rc8-20081004-dolch.orig/drivers/net/3c509.c
+++ linux-mips-2.6.27-rc8-20081004-dolch/drivers/net/3c509.c
@@ -480,9 +480,13 @@ static int pnp_registered;
 
 #ifdef CONFIG_EISA
 static struct eisa_device_id el3_eisa_ids[] = {
+		{ "TCM5090" },
+		{ "TCM5091" },
 		{ "TCM5092" },
 		{ "TCM5093" },
+		{ "TCM5094" },
 		{ "TCM5095" },
+		{ "TCM5098" },
 		{ "" }
 };
 MODULE_DEVICE_TABLE(eisa, el3_eisa_ids);
