From: domen@coderock.org
Subject: [patch 17/19] net/stir4200: replace direct assignment with set_current_state()
Date: Wed, 12 Jan 2005 00:11:00 +0100
Message-ID: <20050111231100.85B611F226@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use set_current_state() instead of direct assignment of
current->state.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/irda/stir4200.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/irda/stir4200.c~set_current_state-drivers_net_irda_stir4200 drivers/net/irda/stir4200.c
--- kj/drivers/net/irda/stir4200.c~set_current_state-drivers_net_irda_stir4200	2005-01-10 18:00:18.000000000 +0100
+++ kj-domen/drivers/net/irda/stir4200.c	2005-01-10 18:00:18.000000000 +0100
@@ -679,7 +679,7 @@ static void turnaround_delay(const struc
 
 	ticks = us / (1000000 / HZ);
 	if (ticks > 0) {
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1 + ticks);
 	} else
 		udelay(us);
_
