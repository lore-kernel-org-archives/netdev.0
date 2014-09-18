From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-09-18
Date: Thu, 18 Sep 2014 12:40:54 +0200
Message-ID: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this is a pull request of 8 patches for current net.

A patch by Roger Quadros for the c_can driver fixes the swapped parameters of
the c_can_hw_raminit_ti() function. Oliver Hartkopp adds the missing PCI ids to
the peak_pci driver to support the single channel PCAN ExpressCard 34 adapter.
David Dueck converts the at91_can driver to use proper clock handling
functions. Then there are 5 patches by David Jander and me which fix several
mailbox related problems in the flexcan driver.

Marc

---

The following changes since commit 6a38792ca8a5da28f65dc42eeb73d9a431f8d0fd:

  scsi: use 'depends' instead of 'select' for SCSI_FC_ATTRS (2014-09-16 16:55:55 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.17-20140918

for you to fetch changes up to e77980e50bc2850599d4d9c0192b67a9ffd6daac:

  can: at91_can: add missing prepare and unprepare of the clock (2014-09-18 11:15:37 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.17-20140918

----------------------------------------------------------------
David Dueck (1):
      can: at91_can: add missing prepare and unprepare of the clock

David Jander (2):
      can: flexcan: correctly initialize mailboxes
      can: flexcan: implement workaround for errata ERR005829

Marc Kleine-Budde (3):
      can: flexcan: mark TX mailbox as TX_INACTIVE
      can: flexcan: put TX mailbox into TX_INACTIVE mode after tx-complete
      can: flexcan: increase FLEXCAN_MCR_MAXMB() macro to 7 bits

Oliver Hartkopp (1):
      can: peak_pci: add PCI ID definition pcie card variant

Roger Quadros (1):
      can: c_can_platform: fix parameters of c_can_hw_raminit_ti()

 drivers/net/can/at91_can.c             |  8 ++++---
 drivers/net/can/c_can/c_can_platform.c |  4 ++--
 drivers/net/can/flexcan.c              | 43 ++++++++++++++++++++++++++++++----
 drivers/net/can/sja1000/peak_pci.c     |  6 ++++-
 4 files changed, 51 insertions(+), 10 deletions(-)

