From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/16] drivers/net/irda: remove exceptional & on function name
Date: Wed, 18 Nov 2009 19:22:05 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181921450.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	arnd@arndb.de, joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932246AbZKRSWE@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/irda/irda-usb.c         |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 5e462b9..e591b36 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -852,7 +852,7 @@ static void irda_usb_receive(struct urb *urb)
 		 * hot unplug of the dongle...
 		 * Lowest effective timer is 10ms...
 		 * Jean II */
-		self->rx_defer_timer.function = &irda_usb_rx_defer_expired;
+		self->rx_defer_timer.function = irda_usb_rx_defer_expired;
 		self->rx_defer_timer.data = (unsigned long) urb;
 		mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
 		return;
