From: domen@coderock.org
Subject: [patch 2/3] net/tms380tr: replace direct assignment with set_current_state()
Date: Fri, 21 Jan 2005 22:03:39 +0100
Message-ID: <20050121210340.8C2871F2D4@trashy.coderock.org>
Cc: domen@coderock.org, nacc@us.ibm.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
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


 kj-domen/drivers/net/tokenring/tms380tr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/tms380tr.c~set_current_state-drivers_net_tokenring_tms380tr drivers/net/tokenring/tms380tr.c
--- kj/drivers/net/tokenring/tms380tr.c~set_current_state-drivers_net_tokenring_tms380tr	2005-01-10 18:00:19.000000000 +0100
+++ kj-domen/drivers/net/tokenring/tms380tr.c	2005-01-10 18:00:19.000000000 +0100
@@ -1244,7 +1244,7 @@ void tms380tr_wait(unsigned long time)
 	
 	tmp = jiffies + time/(1000000/HZ);
 	do {
-  		current->state 		= TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		tmp = schedule_timeout(tmp);
 	} while(time_after(tmp, jiffies));
 #else
_
