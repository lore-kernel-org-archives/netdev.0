From: janitor@sternwelten.at
Subject: [patch 17/18]  net/tms380tr: replace 	direct assignment with set_current_state()
Date: Sun, 31 Oct 2004 00:43:13 +0200
Message-ID: <E1CO1wI-0002kc-5k@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
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

---

 linux-2.6.10-rc1-max/drivers/net/tokenring/tms380tr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/tms380tr.c~set_current_state-drivers_net_tokenring_tms380tr drivers/net/tokenring/tms380tr.c
--- linux-2.6.10-rc1/drivers/net/tokenring/tms380tr.c~set_current_state-drivers_net_tokenring_tms380tr	2004-10-24 17:06:11.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/tokenring/tms380tr.c	2004-10-24 17:06:11.000000000 +0200
@@ -1244,7 +1244,7 @@ void tms380tr_wait(unsigned long time)
 	
 	tmp = jiffies + time/(1000000/HZ);
 	do {
-  		current->state 		= TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		tmp = schedule_timeout(tmp);
 	} while(time_after(tmp, jiffies));
 #else
_
