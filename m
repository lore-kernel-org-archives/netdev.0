From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-10-31
Date: Mon, 31 Oct 2016 21:36:18 +0100
Message-ID: <20161031203620.14384-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of two patches for the upcoming v4.9 release.

The first patch is by Lukas Resch for the sja1000 plx_pci driver that adds
support for Moxa CAN devices. The second patch is by Oliver Hartkopp and fixes
a potential kernel panic in the CAN broadcast manager.

regards,
Marc

---

The following changes since commit 46d0847cdd4a3fc1920e56827b9189b9a105d362:

  mlxsw: spectrum: Fix incorrect reuse of MID entries (2016-10-31 15:34:43 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.9-20161031

for you to fetch changes up to deb507f91f1adbf64317ad24ac46c56eeccfb754:

  can: bcm: fix warning in bcm_connect/proc_register (2016-10-31 20:48:19 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.9-20161031

----------------------------------------------------------------
Lukas Resch (1):
      can: sja1000: plx_pci: Add support for Moxa CAN devices

Oliver Hartkopp (1):
      can: bcm: fix warning in bcm_connect/proc_register

 drivers/net/can/sja1000/plx_pci.c | 18 ++++++++++++++++++
 net/can/bcm.c                     | 32 +++++++++++++++++++++++---------
 2 files changed, 41 insertions(+), 9 deletions(-)


