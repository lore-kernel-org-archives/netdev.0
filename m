From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Sun, 7 Nov 2004 21:32:36 -0500
Message-ID: <20041108023236.GA13437@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/Kconfig            |    2 +-
 drivers/net/hamradio/hdlcdrv.c |    2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

through these ChangeSets:

<miltonm@realtime.net> (04/11/06 1.2473)
   [PATCH] hamradio/hdlcdrv: undo duplicat patch application
   
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<miltonm@realtime.net> (04/11/06 1.2472)
   [PATCH] net/Kconfig: undo duplicate patch application
   
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2004-11-07 21:31:54 -05:00
+++ b/drivers/net/Kconfig	2004-11-07 21:31:54 -05:00
@@ -1681,7 +1681,7 @@
 	  (e.g. VT8235).
 
 	  To compile this driver as a module, choose M here. The module
-	  will be called via-velocity.
+	  will be called via-rhine.
 
 config VIA_RHINE_MMIO
 	bool "Use MMIO instead of PIO"
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	2004-11-07 21:31:54 -05:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2004-11-07 21:31:54 -05:00
@@ -549,8 +549,6 @@
 
 	netif_stop_queue(dev);
 
-	netif_stop_queue(dev);
-
 	if (s->ops && s->ops->close)
 		i = s->ops->close(dev);
 	if (s->skb)
