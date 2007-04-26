From: akpm@linux-foundation.org
Subject: [patch 11/11] 3C509: Remove unnecessary include of <linux/pm_legacy.h>
Date: Thu, 26 Apr 2007 00:23:25 -0700
Message-ID: <200704260723.l3Q7NP9Y023850@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@mindspring.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:37368 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933552AbXDZH6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:58:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@mindspring.com>

Remove the apparently redundant include of <linux/pm_legacy.h>.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c509.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN drivers/net/3c509.c~3c509-remove-unnecessary-include-of-linux-pm_legacyh drivers/net/3c509.c
--- a/drivers/net/3c509.c~3c509-remove-unnecessary-include-of-linux-pm_legacyh
+++ a/drivers/net/3c509.c
@@ -83,7 +83,6 @@ static int max_interrupt_work = 10;
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/pm.h>
-#include <linux/pm_legacy.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>	/* for udelay() */
 #include <linux/spinlock.h>
_
