From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 0/5] remove custom implementation of hex_to_bin()
Date: Fri, 23 Jul 2010 16:18:05 +0300
Message-ID: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove custom implementation of recently introduced hex_to_bin() method. All
changes related to the network subsystem in the kernel.

Andy Shevchenko (5):
  drivers: atm: don't use private copy of hex_to_bin()
  drivers: net: use newly introduced hex_to_bin()
  usb: usbnet: use newly introduced hex_to_bin()
  wireless: use newly introduced hex_to_bin()
  net: core: don't use own hex_to_bin() method

 drivers/atm/nicstar.c         |   15 ++-------------
 drivers/net/ksz884x.c         |   11 +++++------
 drivers/net/usb/usbnet.c      |   13 ++-----------
 drivers/net/wireless/ray_cs.c |   23 ++---------------------
 net/core/pktgen.c             |   36 ++++++++++++------------------------
 5 files changed, 23 insertions(+), 75 deletions(-)
