From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCH 0/3] net: fec fixes
Date: Fri,  5 Feb 2010 10:56:19 -0800
Message-ID: <cover.1265396105.git.amit.kucheria@canonical.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, gerg@uclinux.org,
	u.kleine-koenig@pengutronix.de, amit.kucheria@verdurent.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some fixes to the fec driver to get it to work on the Freescale i.MX5 SoC
platform

Amit Kucheria (2):
  fec: Add LAN8700 phy support
  fec: Add ARCH_MX5 as a dependency

Rob Herring (1):
  fec: fix uninitialized rx buffer usage

 drivers/net/Kconfig |    3 +-
 drivers/net/fec.c   |   78 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 52 insertions(+), 29 deletions(-)
