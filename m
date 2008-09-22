From: akpm@linux-foundation.org
Subject: [patch 19/21] smc911x: remove duplicate debug printout
Date: Mon, 22 Sep 2008 14:52:27 -0700
Message-ID: <200809222152.m8MLqRpt031993@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, damm@igel.co.jp,
	jacmet@sunsite.dk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42990 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049AbYIVV5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

Remove duplicated debug printout.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/smc911x.c~smc911x-remove-duplicate-debug-printout drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~smc911x-remove-duplicate-debug-printout
+++ a/drivers/net/smc911x.c
@@ -1174,8 +1174,6 @@ static irqreturn_t smc911x_interrupt(int
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
-
 	return IRQ_HANDLED;
 }
 
_
