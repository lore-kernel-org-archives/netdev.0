From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: chip clock rate typo
Date: Wed, 19 Jul 2006 14:08:42 -0700
Message-ID: <20060719140842.326a11ac@localhost.localdomain>
References: <200607222330.30842.mb@bu3sch.de>
	<20060719133535.40e490fc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32937 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932263AbWGXWDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 18:03:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060719133535.40e490fc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Okay, Fix both typo's in one patch .The impact is that the incorrect value
was being computed for blinking LED and interrupt moderation values.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -516,10 +516,7 @@ static int skge_set_pauseparam(struct ne
 /* Chip internal frequency for clock calculations */
 static inline u32 hwkhz(const struct skge_hw *hw)
 {
-	if (hw->chip_id == CHIP_ID_GENESIS)
-		return 53215; /* or:  53.125 MHz */
-	else
-		return 78215; /* or:  78.125 MHz */
+	return (hw->chip_id == CHIP_ID_GENESIS) ? 53125 : 78125;
 }
 
 /* Chip HZ to microseconds */



