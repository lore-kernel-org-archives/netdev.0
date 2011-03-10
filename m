From: j223yang@asset.uwaterloo.ca
Subject: [Patch]ariadne: remove redundant NULL check
Date: Thu, 10 Mar 2011 12:20:31 -0500
Message-ID: <20110310172031.GA10734@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply remove redundant 'dev' NULL check. 

Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
---
 ariadne.c |    5 -----
 1 file changed, 5 deletions(-)

--- a/drivers/net/ariadne.c	2011-03-10 11:20:14.076039323 -0500
+++ b/drivers/net/ariadne.c	2011-03-10 11:21:59.111164537 -0500
@@ -425,11 +425,6 @@ static irqreturn_t ariadne_interrupt(int
     int csr0, boguscnt;
     int handled = 0;
 
-    if (dev == NULL) {
-	printk(KERN_WARNING "ariadne_interrupt(): irq for unknown device.\n");
-	return IRQ_NONE;
-    }
-
     lance->RAP = CSR0;			/* PCnet-ISA Controller Status */
 
     if (!(lance->RDP & INTR))		/* Check if any interrupt has been */
