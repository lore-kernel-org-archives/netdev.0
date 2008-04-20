From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] drivers/built-in.o: In function
 `rt2x00leds_resume': : undefined reference to `led_classdev_resume'
Date: Sun, 20 Apr 2008 03:01:41 -0700 (PDT)
Message-ID: <20080420.030141.07052649.davem@davemloft.net>
References: <20080420.020557.231970202.davem@davemloft.net>
	<200804201131.01504.IvDoorn@gmail.com>
	<20080420.024704.02026708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl
To: ivdoorn@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080420.024704.02026708.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 20 Apr 2008 02:47:04 -0700 (PDT)

> I think NEW_LEDS can be completely eliminated.

Actually, more accurately, I propose removing the HAS_IOMEM
restriction.

This allows LEDS infrastructure to be select'd by drivers safely.

diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
index 859814f..91d36d0 100644
--- a/drivers/leds/Kconfig
+++ b/drivers/leds/Kconfig
@@ -1,6 +1,5 @@
 menuconfig NEW_LEDS
 	bool "LED Support"
-	depends on HAS_IOMEM
 	help
 	  Say Y to enable Linux LED support.  This allows control of supported
 	  LEDs from both userspace and optionally, by kernel events (triggers).
