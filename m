From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/hamradio/: cleanups
Date: Tue, 19 Apr 2005 04:40:07 +0200
Message-ID: <20050419024007.GU5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- mkiss.c: make a needlessly global variable static
- dmascc.c: remove the unused global function dmascc_setup

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/hamradio/dmascc.c |   10 ----------
 drivers/net/hamradio/mkiss.c  |    2 +-
 2 files changed, 1 insertion(+), 11 deletions(-)

--- linux-2.6.12-rc2-mm3-full/drivers/net/hamradio/dmascc.c.old	2005-04-19 03:04:36.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/hamradio/dmascc.c	2005-04-19 03:04:57.000000000 +0200
@@ -311,16 +311,6 @@
 	}
 }
 
-#ifndef MODULE
-void __init dmascc_setup(char *str, int *ints)
-{
-	int i;
-
-	for (i = 0; i < MAX_NUM_DEVS && i < ints[0]; i++)
-		io[i] = ints[i + 1];
-}
-#endif
-
 static int __init dmascc_init(void)
 {
 	int h, i, j, n;
--- linux-2.6.12-rc2-mm3-full/drivers/net/hamradio/mkiss.c.old	2005-04-19 03:05:20.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/hamradio/mkiss.c	2005-04-19 03:05:30.000000000 +0200
@@ -65,7 +65,7 @@
 
 static ax25_ctrl_t **ax25_ctrls;
 
-int ax25_maxdev = AX25_MAXDEV;		/* Can be overridden with insmod! */
+static int ax25_maxdev = AX25_MAXDEV;	/* Can be overridden with insmod! */
 
 static struct tty_ldisc	ax_ldisc;
 
