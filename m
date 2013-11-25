From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-11-25
Date: Mon, 25 Nov 2013 21:56:24 +0100
Message-ID: <1385412987-31205-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a pull request for v3.13, i.e. net/master. It consists of a patch by
Oliver Hartkopp which fixes some corner cases in the interrupt handler of the
sja1000 driver. Then there are two patches for the c_can dirver. One by me,
which fixes a runtime pm related "scheduling while atomic" error and patch by
Holger Bechtold that fixes the calculation of the transmitted bytes.

regards,
Marc

---

The following changes since commit 2c7a9dc1641664173211c4ebc5db510a08684c46:

  be2net: Avoid programming permenant MAC by BE3-R VFs (2013-11-23 15:11:07 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.13

for you to fetch changes up to 7ee330c7b3b738847bf297912b371bbcec3bc994:

  can: c_can: fix calculation of transmitted bytes on tx complete (2013-11-25 21:48:54 +0100)

----------------------------------------------------------------
Holger Bechtold (1):
      can: c_can: fix calculation of transmitted bytes on tx complete

Marc Kleine-Budde (1):
      can: c_can: don't call pm_runtime_get_sync() from interrupt context

Oliver Hartkopp (1):
      can: sja1000: fix {pre,post}_irq() handling and IRQ handler return value

 drivers/net/can/c_can/c_can.c     | 22 ++++++++++++++++------
 drivers/net/can/sja1000/sja1000.c | 17 +++++++++--------
 2 files changed, 25 insertions(+), 14 deletions(-)


