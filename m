From: Jeff Garzik <jgarzik@pobox.com>
Subject: [git patch] net driver build fix
Date: Tue, 13 Dec 2005 11:37:59 -0500
Message-ID: <20051213163759.GA23530@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932390AbVLMQiN@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

to receive the following updates:

 drivers/net/skge.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Jeff Garzik:
      [netdrvr skge] fix build

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 8b6e2a1..00d6830 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2280,7 +2280,7 @@ static int skge_xmit_frame(struct sk_buf
  	}
 
 	if (unlikely(skge->tx_avail < skb_shinfo(skb)->nr_frags +1)) {
-		if (!netif_stopped(dev)) {
+		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 
 			printk(KERN_WARNING PFX "%s: ring full when queue awake!\n",
