From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V10 10/15] posix clocks: remove useless default methods
Date: Thu, 27 Jan 2011 11:58:34 +0100
Message-ID: <16925dc1baef5f57599b3fde55f8775d7b17e741.1296124770.git.richard.cochran@omicron.at>
References: <cover.1296124770.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1296124770.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For the k_clocks which do not allow timers or sleeping, it does not make
sense to use the default "common" methods for these kinds of functions.
Thus we simply remove them.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 kernel/posix-timers.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 7a3683d..f227474 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -262,11 +262,6 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
-		/* defaults: */
-		.nsleep_restart	= common_nsleep_restart,
-		.timer_del	= common_timer_del,
-		.timer_get	= common_timer_get,
-		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_realtime_coarse = {
 		.clock_getres = posix_get_coarse_res,
@@ -275,11 +270,6 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
-		/* defaults: */
-		.nsleep_restart	= common_nsleep_restart,
-		.timer_del	= common_timer_del,
-		.timer_get	= common_timer_get,
-		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_monotonic_coarse = {
 		.clock_getres = posix_get_coarse_res,
@@ -288,11 +278,6 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
-		/* defaults: */
-		.nsleep_restart	= common_nsleep_restart,
-		.timer_del	= common_timer_del,
-		.timer_get	= common_timer_get,
-		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_posix_cpu = {
 		.clock_getres	= posix_cpu_clock_getres,
-- 
1.7.0.4
