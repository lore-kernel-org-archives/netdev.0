From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: chip clock rate typo
Date: Wed, 19 Jul 2006 13:35:35 -0700
Message-ID: <20060719133535.40e490fc@localhost.localdomain>
References: <200607222330.30842.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41372 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751449AbWGXVQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 17:16:28 -0400
To: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <200607222330.30842.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch spotted this typo.  The impact is that the incorrect value
was being computed for blinking LED and interrupt moderation values.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -519,7 +519,7 @@ static inline u32 hwkhz(const struct skg
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		return 53215; /* or:  53.125 MHz */
 	else
-		return 78215; /* or:  78.125 MHz */
+		return 78125; /* or:  78.125 MHz */
 }
 
 /* Chip HZ to microseconds */
