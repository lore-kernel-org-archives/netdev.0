From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/ieee80211/ieee80211_tx.c: swapped memset arguments
Date: Sat, 9 Apr 2005 20:03:48 +0200
Message-ID: <20050409180348.GC3632@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Juhl <juhl-lkml@dif.dk>, Maciej Soltysiak <solt2@dns.toxicfilms.tv>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix swapped memset() arguments in  net/ieee80211/ieee80211_tx.c  
found by Maciej Soltysiak.

Patch by Jesper Juhl.

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was sent by Jesper Juhl on:
- 3 Apr 2005

--- linux-2.6.12-rc1-mm4-orig/net/ieee80211/ieee80211_tx.c	2005-03-31 21:20:08.000000000 +0200
+++ linux-2.6.12-rc1-mm4/net/ieee80211/ieee80211_tx.c	2005-04-03 00:34:22.000000000 +0200
@@ -223,7 +223,7 @@ struct ieee80211_txb *ieee80211_alloc_tx
 	if (!txb)
 		return NULL;
 
-	memset(txb, sizeof(struct ieee80211_txb), 0);
+	memset(txb, 0, sizeof(struct ieee80211_txb));
 	txb->nr_frags = nr_frags;
 	txb->frag_size = txb_size;
 
