From: janitor@sternwelten.at
Subject: [patch 07/16]  net/ewrk3: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:03:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cG6-0007pN-FM@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/ewrk3.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ewrk3.c~msleep-drivers_net_ewrk3 drivers/net/ewrk3.c
--- linux-2.6.9-rc1-bk7/drivers/net/ewrk3.c~msleep-drivers_net_ewrk3	2004-09-01 19:35:29.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/ewrk3.c	2004-09-01 19:35:29.000000000 +0200
@@ -1681,8 +1681,7 @@ static int ewrk3_ethtool_ioctl(struct ne
 
 			/* Wait a little while */
 			spin_unlock_irqrestore(&lp->hw_lock, flags);
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ>>2);
+			msleep(250);
 			spin_lock_irqsave(&lp->hw_lock, flags);
 
 			/* Exit if we got a signal */

_
