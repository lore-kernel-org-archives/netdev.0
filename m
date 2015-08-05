From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 0/5] net: rfkill: gpio: replace platform data with build-in property
Date: Wed,  5 Aug 2015 16:39:02 +0300
Message-ID: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The first patch adds a few helper macros for build-in property
creation and the second makes it possible to get the rfkill type
index based on name. The rest deal with rfkill-gpio.

Cheers,


Heikki Krogerus (5):
  device property: helper macros for property entry creation
  net: rfkill: add rfkill_find_type function
  net: rfkill: gpio: get the name and type from device property
  ARM: tegra: use build-in device properties with rfkill_gpio
  net: rfkill: gpio: remove rfkill_gpio_platform_data

 arch/arm/mach-tegra/board-paz00.c | 17 +++++++-----
 include/linux/property.h          | 35 ++++++++++++++++++++++++
 include/linux/rfkill-gpio.h       | 37 -------------------------
 include/linux/rfkill.h            | 15 +++++++++++
 net/rfkill/Kconfig                |  3 +--
 net/rfkill/core.c                 | 57 ++++++++++++++++++++-------------------
 net/rfkill/rfkill-gpio.c          | 24 ++++++++---------
 7 files changed, 101 insertions(+), 87 deletions(-)
 delete mode 100644 include/linux/rfkill-gpio.h

-- 
2.4.6
