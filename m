From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: sched_timeout() sets curr_state (atm)
Date: Sun, 5 Oct 2003 20:34:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005203425.5e474ccd.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.0-test6-current.

--
~Randy


From: Alexey Dobriyan <adobriyan@mail.ru>


 linux-260-test6-kj1-rddunlap/drivers/atm/he.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/atm/he.c~atm_he_taskrun drivers/atm/he.c
--- linux-260-test6-kj1/drivers/atm/he.c~atm_he_taskrun	2003-09-29 17:32:02.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/drivers/atm/he.c	2003-09-29 17:32:02.000000000 -0700
@@ -2633,7 +2633,6 @@ he_close(struct atm_vcc *vcc)
 		       (retry < MAX_RETRY)) {
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			(void) schedule_timeout(sleep);
-			set_current_state(TASK_RUNNING);
 			if (sleep < HZ)
 				sleep = sleep * 2;
 

_
