From: janitor@sternwelten.at
Subject: [patch 5/8]  irda/tekram-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:05:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIb-00081o-MO@sputnik>
Cc: jgarzik@pobox.com, jt@hpl.hp.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/irda/tekram-sir.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/irda/tekram-sir.c~msleep-drivers_net_irda_tekram-sir drivers/net/irda/tekram-sir.c
--- linux-2.6.9-rc1-bk7/drivers/net/irda/tekram-sir.c~msleep-drivers_net_irda_tekram-sir	2004-09-01 19:35:32.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/irda/tekram-sir.c	2004-09-01 19:35:32.000000000 +0200
@@ -210,8 +210,7 @@ static int tekram_reset(struct sir_dev *
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
 
 	/* Should sleep 1 ms */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(1));
+	msleep(1);
 
 	/* Set DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);

_
