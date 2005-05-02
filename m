From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/ewrk3.c: remove dead code
Date: Mon, 2 May 2005 03:47:00 +0200
Message-ID: <20050502014700.GW3592@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261652AbVEBB42@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes some obviously dead code found by the Coverity 
checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 10 Apr 2005

 drivers/net/ewrk3.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

--- linux-2.6.12-rc2-mm2-full/drivers/net/ewrk3.c.old	2005-04-09 22:03:49.000000000 +0200
+++ linux-2.6.12-rc2-mm2-full/drivers/net/ewrk3.c	2005-04-09 22:04:15.000000000 +0200
@@ -1308,15 +1308,9 @@ static int __init eisa_probe(struct net_
 	if (ioaddr < 0x1000)
 		goto out;
 
-	if (ioaddr == 0) {	/* Autoprobing */
-		iobase = EISA_SLOT_INC;		/* Get the first slot address */
-		i = 1;
-		maxSlots = MAX_EISA_SLOTS;
-	} else {		/* Probe a specific location */
-		iobase = ioaddr;
-		i = (ioaddr >> 12);
-		maxSlots = i + 1;
-	}
+	iobase = ioaddr;
+	i = (ioaddr >> 12);
+	maxSlots = i + 1;
 
 	for (i = 1; (i < maxSlots) && (dev != NULL); i++, iobase += EISA_SLOT_INC) {
 		if (EISA_signature(name, EISA_ID) == 0) {

k
