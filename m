From: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCHv3 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Tue,  1 Apr 2014 17:02:51 +0300
Message-ID: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I hope this one is OK with everyone.

Changes since v2:
- Instead of changing the driver to use only indexed gpios, just
  hard-coding the names.

Changes since v1:
- Removed the gpio entries from arch/arm/mach-tegra/board-paz00.c


Heikki Krogerus (5):
  ARM: tegra: remove obsolete gpio entries
  net: rfkill: gpio: remove unused and obsolete platform parameters
  net: rfkill: gpio: add ACPI ID for GPS module on Lenovo Miix2
  net: rfkill: gpio: add ACPI IDs for a Broadcom bluetooth chip
  net: rfkill: gpio: hard-code the gpio names

 arch/arm/mach-tegra/board-paz00.c |  4 +---
 include/linux/rfkill-gpio.h       | 10 ----------
 net/rfkill/rfkill-gpio.c          | 40 +++++++++------------------------------
 3 files changed, 10 insertions(+), 44 deletions(-)

-- 
1.9.1
