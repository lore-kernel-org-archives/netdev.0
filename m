From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/hamradio/dmascc.c: remove dmascc_setup()
Date: Mon, 31 Oct 2005 01:33:45 +0100
Message-ID: <20051031003345.GB8009@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932420AbVJaAdr@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems dmascc_setup() is a leftover time before dmascc_init() was 
there.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/hamradio/dmascc.c |   10 ----------
 1 file changed, 10 deletions(-)

--- linux-2.6.14-rc5-mm1-full/drivers/net/hamradio/dmascc.c.old	2005-10-31 01:21:39.000000000 +0100
+++ linux-2.6.14-rc5-mm1-full/drivers/net/hamradio/dmascc.c	2005-10-31 01:21:49.000000000 +0100
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
