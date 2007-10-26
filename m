From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 3] isdn: incorrect assignments in if
Date: Fri, 26 Oct 2007 19:26:25 +0200
Message-ID: <47222341.9040609@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:60522 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099AbXJZR02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 13:26:28 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out3.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IlSx1-00064J-5I
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 19:26:27 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    incorrect assignments in if
    
    Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 948a9b2..ed610ed 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -883,7 +883,7 @@ setup_elsa_isa(struct IsdnCard *card)
 	val += 'A' - 3;
 	if (val == 'B' || val == 'C')
 		val ^= 1;
-	if ((cs->subtyp == ELSA_PCFPRO) && (val = 'G'))
+	if ((cs->subtyp == ELSA_PCFPRO) && (val == 'G'))
 		val = 'C';
 	printk(KERN_INFO
 	       "Elsa: %s found at %#lx Rev.:%c IRQ %d\n",
