From: janitor@sternwelten.at
Subject: [patch 1/8]  irda/act200l-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:05:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIF-0007yy-Lb@sputnik>
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

 linux-2.6.9-rc1-bk7-max/drivers/net/irda/act200l-sir.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/irda/act200l-sir.c~msleep-drivers_net_irda_act200l-sir drivers/net/irda/act200l-sir.c
--- linux-2.6.9-rc1-bk7/drivers/net/irda/act200l-sir.c~msleep-drivers_net_irda_act200l-sir	2004-09-01 19:35:31.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/irda/act200l-sir.c	2004-09-01 19:35:31.000000000 +0200
@@ -177,8 +177,7 @@ static int act200l_change_speed(struct s
 
 	/* Write control bytes */
 	sirdev_raw_write(dev, control, 3);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(5));
+	msleep(5);
 
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);

_
