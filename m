From: akpm@linux-foundation.org
Subject: [patch 06/12] hamradio: add missing sanity check to tty operation
Date: Wed, 30 Jul 2008 12:38:59 -0700
Message-ID: <200807301938.m6UJcxbO012515@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	eugeneteo@kernel.sg, alan@redhat.com, eteo@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57665 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754907AbYG3Tk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:40:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Teo <eugeneteo@kernel.sg>

Add missing sanity check to tty operation.

Acked-by: Alan Cox <alan@redhat.com>
Signed-off-by: Eugene Teo <eteo@redhat.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/mkiss.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/hamradio/mkiss.c~hamradio-add-missing-sanity-check-to-tty-operation drivers/net/hamradio/mkiss.c
--- a/drivers/net/hamradio/mkiss.c~hamradio-add-missing-sanity-check-to-tty-operation
+++ a/drivers/net/hamradio/mkiss.c
@@ -548,7 +548,7 @@ static int ax_xmit(struct sk_buff *skb, 
 		}
 
 		printk(KERN_ERR "mkiss: %s: transmit timed out, %s?\n", dev->name,
-		       (ax->tty->ops->chars_in_buffer(ax->tty) || ax->xleft) ?
+		       (tty_chars_in_buffer(ax->tty) || ax->xleft) ?
 		       "bad line quality" : "driver error");
 
 		ax->xleft = 0;
_
