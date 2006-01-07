From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] kernel/posix-timers.c: remove do_posix_clock_notimer_create()
Date: Sat, 7 Jan 2006 23:32:10 +0100
Message-ID: <20060107223210.GB3774@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752594AbWAGWcP@vger.kernel.org>
To: george@mvista.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is there any reason for this function that is neither used nor has any 
real contents?


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/linux/posix-timers.h |    1 -
 kernel/posix-timers.c        |    6 ------
 2 files changed, 7 deletions(-)

--- linux-2.6.15-mm2-full/include/linux/posix-timers.h.old	2006-01-07 23:13:08.000000000 +0100
+++ linux-2.6.15-mm2-full/include/linux/posix-timers.h	2006-01-07 23:13:17.000000000 +0100
@@ -84,7 +84,6 @@
 void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock);
 
 /* error handlers for timer_create, nanosleep and settime */
-int do_posix_clock_notimer_create(struct k_itimer *timer);
 int do_posix_clock_nonanosleep(const clockid_t, int flags, struct timespec *,
 			       struct timespec __user *);
 int do_posix_clock_nosettime(const clockid_t, struct timespec *tp);
--- linux-2.6.15-mm2-full/kernel/posix-timers.c.old	2006-01-07 23:13:25.000000000 +0100
+++ linux-2.6.15-mm2-full/kernel/posix-timers.c	2006-01-07 23:13:30.000000000 +0100
@@ -875,12 +875,6 @@
 }
 EXPORT_SYMBOL_GPL(do_posix_clock_nosettime);
 
-int do_posix_clock_notimer_create(struct k_itimer *timer)
-{
-	return -EINVAL;
-}
-EXPORT_SYMBOL_GPL(do_posix_clock_notimer_create);
-
 int do_posix_clock_nonanosleep(const clockid_t clock, int flags,
 			       struct timespec *t, struct timespec __user *r)
 {
