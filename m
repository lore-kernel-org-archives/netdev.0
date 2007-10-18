From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] r8169 - trivial fix - printk(PFX KERN_<level>...) to
	printk(KERN_<level> PFX...)
Date: Thu, 18 Oct 2007 12:01:46 -0700
Message-ID: <1192734106.23980.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3134 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759061AbXJRTBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:01:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..9c11087 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2310,7 +2311,7 @@ static void rtl8169_reinit_task(struct work_struct *work)
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
 		if (net_ratelimit() && netif_msg_drv(tp)) {
-			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
+			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
 			       " Rescheduling.\n", dev->name, ret);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
@@ -2342,7 +2343,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 		netif_wake_queue(dev);
 	} else {
 		if (net_ratelimit() && netif_msg_intr(tp)) {
-			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
+			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
 			       dev->name);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);


