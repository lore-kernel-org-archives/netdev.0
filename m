From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] irda: toim3232-sir: delete some dead code
Date: Fri, 8 Jan 2016 14:04:04 +0300
Message-ID: <20160108110404.GL32195@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed this code because it has a typo in the module_param(),
the "trs" at the end of "toim3232fliptrs" should be "rts".  But it's
dead code so instead of fixing it, I just deleted it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/irda/toim3232-sir.c b/drivers/net/irda/toim3232-sir.c
index 6d2f559..b977d6d 100644
--- a/drivers/net/irda/toim3232-sir.c
+++ b/drivers/net/irda/toim3232-sir.c
@@ -130,16 +130,6 @@ static int toim3232delay = 150;	/* default is 150 ms */
 module_param(toim3232delay, int, 0);
 MODULE_PARM_DESC(toim3232delay, "toim3232 dongle write complete delay");
 
-#if 0
-static int toim3232flipdtr = 0;	/* default is DTR high to reset */
-module_param(toim3232flipdtr, int, 0);
-MODULE_PARM_DESC(toim3232flipdtr, "toim3232 dongle invert DTR (Reset)");
-
-static int toim3232fliprts = 0;	/* default is RTS high for baud change */
-module_param(toim3232fliptrs, int, 0);
-MODULE_PARM_DESC(toim3232fliprts, "toim3232 dongle invert RTS (BR/D)");
-#endif
-
 static int toim3232_open(struct sir_dev *);
 static int toim3232_close(struct sir_dev *);
 static int toim3232_change_speed(struct sir_dev *, unsigned);
