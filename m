From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-11-27
Date: Wed, 27 Nov 2013 22:11:31 +0100
Message-ID: <1385586695-11134-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is an extention of my pull request from 2013-11-25, it includes an
additional patch.

This series consists of a patch by Oliver Hartkopp which fixes some corner
cases in the interrupt handler of the sja1000 driver. Then there are two
patches for the c_can dirver. One by me, which fixes a runtime pm related
"scheduling while atomic" error and patch by Holger Bechtold that fixes the
calculation of the transmitted bytes.

The fourth patch (the additional one) is by me, it corrects the clock usage in
the flexcan driver.

regards,
Marc

---

The following changes since commit 2c7a9dc1641664173211c4ebc5db510a08684c46:

  be2net: Avoid programming permenant MAC by BE3-R VFs (2013-11-23 15:11:07 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.13-20131127

for you to fetch changes up to 1a3e5173f5e72cbf7f0c8927b33082e361c16d72:

  can: flexcan: use correct clock as base for bit rate calculation (2013-11-26 15:39:47 +0100)

----------------------------------------------------------------
Holger Bechtold (1):
      can: c_can: fix calculation of transmitted bytes on tx complete

Marc Kleine-Budde (2):
      can: c_can: don't call pm_runtime_get_sync() from interrupt context
      can: flexcan: use correct clock as base for bit rate calculation

Oliver Hartkopp (1):
      can: sja1000: fix {pre,post}_irq() handling and IRQ handler return value

 drivers/net/can/c_can/c_can.c     | 22 ++++++++++++++++------
 drivers/net/can/flexcan.c         |  2 +-
 drivers/net/can/sja1000/sja1000.c | 17 +++++++++--------
 3 files changed, 26 insertions(+), 15 deletions(-)


