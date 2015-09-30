From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] ipv4: ktime_get_ms_of_day() can be static
Date: Wed, 30 Sep 2015 20:15:49 +0800
Message-ID: <20150930121549.GA204787@lkp-ib04.intel.com>
References: <201509302049.z9c32MsP%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-12-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 timekeeping.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 5611a6d..46b847a 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -847,7 +847,7 @@ time64_t ktime_get_real_seconds(void)
 EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
 
 #if IS_ENABLED(CONFIG_INET)
-u32 ktime_get_ms_of_day(void)
+static u32 ktime_get_ms_of_day(void)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
 	struct timespec64 now;
