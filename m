From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-03-27
Date: Wed, 27 Mar 2013 15:05:26 +0100
Message-ID: <1364393128-19701-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a patch series for net for the v3.9 release cycle. Fengguang Wu found
two problems with the sja1000 drivers:

A macro in the SH architecture collides with one in the sja1000 driver. I
created a minimal patch suited for stable, only changing this particular
define. (Once net is merged back to net-next, I'll post a patch to uniformly
use a SJA1000_ prefix for the sja100 private defines.) If you prefer, I can
squash both patches together.

Fengguang further noticed that the peak pcmcia driver will not compile on archs
without ioport support. I created a patch to limit the driver to archs which
select HAS_IOPORT in Kconfig.

regards,
Marc

---

The following changes since commit b175293ccc98ab84e93d25472d7422b4a897614b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-03-26 14:24:29 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git fixes-for-3.9

for you to fetch changes up to 3fd33497f80aa528ded0db2851b48638635d5caa:

  can: sja1000: limit PEAK PCAN-PC Card to HAS_IOPORT (2013-03-27 14:51:49 +0100)

----------------------------------------------------------------
Marc Kleine-Budde (2):
      can: sja1000: fix define conflict on SH
      can: sja1000: limit PEAK PCAN-PC Card to HAS_IOPORT

 drivers/net/can/sja1000/Kconfig   | 1 +
 drivers/net/can/sja1000/plx_pci.c | 4 ++--
 drivers/net/can/sja1000/sja1000.c | 6 +++---
 drivers/net/can/sja1000/sja1000.h | 2 +-
 4 files changed, 7 insertions(+), 6 deletions(-)


