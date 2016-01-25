From: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCHv2 0/4] net: rfkill: gpio: replace platform data with build-in property
Date: Mon, 25 Jan 2016 12:03:45 +0300
Message-ID: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

The changes to the unified properties interface that I have been
waiting for are finally available in v4.5-rc1.


Heikki Krogerus (4):
  net: rfkill: add rfkill_find_type function
  net: rfkill: gpio: get the name and type from device property
  ARM: tegra: use build-in device properties with rfkill_gpio
  net: rfkill: gpio: remove rfkill_gpio_platform_data

 arch/arm/mach-tegra/board-paz00.c | 17 +++++++-----
 include/linux/rfkill-gpio.h       | 37 -------------------------
 include/linux/rfkill.h            | 15 +++++++++++
 net/rfkill/Kconfig                |  3 +--
 net/rfkill/core.c                 | 57 ++++++++++++++++++++-------------------
 net/rfkill/rfkill-gpio.c          | 24 ++++++++---------
 6 files changed, 66 insertions(+), 87 deletions(-)
 delete mode 100644 include/linux/rfkill-gpio.h

-- 
2.7.0.rc3
