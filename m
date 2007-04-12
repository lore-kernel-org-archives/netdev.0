From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] 3C509: Remove unnecessary include of <linux/pm_legacy.h>
Date: Thu, 12 Apr 2007 16:46:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0704121644370.20699@CPE00045a9c397f-CM001225dbafb6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:39688 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbXDLUss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 16:48:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove the apparently redundant include of <linux/pm_legacy.h>.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

compile-tested on x86, in preparation for the day when the legacy PM
code goes away.


diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index f791bf0..a8ea346 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -83,7 +83,6 @@ static int max_interrupt_work = 10;
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/pm.h>
-#include <linux/pm_legacy.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>	/* for udelay() */
 #include <linux/spinlock.h>
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
