From: domen@coderock.org
Subject: [patch 11/19] net/tekram-sir: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:40 +0100
Message-ID: <20050111231040.E5DD51F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout() to guarantee the
task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/irda/tekram-sir.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/irda/tekram-sir.c~msleep_interruptible-drivers_net_irda_tekram-sir drivers/net/irda/tekram-sir.c
--- kj/drivers/net/irda/tekram-sir.c~msleep_interruptible-drivers_net_irda_tekram-sir	2005-01-10 18:00:06.000000000 +0100
+++ kj-domen/drivers/net/irda/tekram-sir.c	2005-01-10 18:00:06.000000000 +0100
@@ -210,8 +210,7 @@ static int tekram_reset(struct sir_dev *
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
 
 	/* Should sleep 1 ms */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(1));
+	msleep(1);
 
 	/* Set DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
_
