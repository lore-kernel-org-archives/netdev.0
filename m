From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] smc911x: remove duplicate debug printout
Date: Mon, 08 Sep 2008 14:03:16 +0900
Message-ID: <20080908050316.11556.70782.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, jgarzik@redhat.com,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:6780 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbYIHFEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 01:04:25 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1293962rvb.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 22:04:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

Remove duplicated debug printout.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc911x.c |    2 --
 1 file changed, 2 deletions(-)

--- 0001/drivers/net/smc911x.c
+++ work/drivers/net/smc911x.c	2008-08-29 11:54:00.000000000 +0900
@@ -1174,8 +1174,6 @@ static irqreturn_t smc911x_interrupt(int
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
-
 	return IRQ_HANDLED;
 }
 
