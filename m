From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-04-12
Date: Fri, 12 Apr 2013 13:11:55 +0200
Message-ID: <1365765117-28316-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's another fix for the v3.9 release cycle, if not too late:

Christoph Fritz fixed the device tree property handling on little endian
systems in the sja1000 device tree driver. It was Mylene Josserand who noticed
that the mcp251x spi CAN driver cannot request its interrupt anymore, as the
driver is using a threaded interrupt handler without a primary one and without
specifying IRQF_ONESHOT (which is needed since v3.5). A patch by me fixes this
problem.

regards,
Marc

---

The following changes since commit 50bceae9bd3569d56744882f3012734d48a1d413:

  tcp: Reallocate headroom if it would overflow csum_start (2013-04-11 18:12:41 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.9

for you to fetch changes up to 0443de5fbf224abf41f688d8487b0c307dc5a4b4:

  can: sja1000: fix handling on dt properties on little endian systems (2013-04-12 13:03:01 +0200)

----------------------------------------------------------------
Christoph Fritz (1):
      can: sja1000: fix handling on dt properties on little endian systems

Marc Kleine-Budde (1):
      can: mcp251x: add missing IRQF_ONESHOT to request_threaded_irq

 drivers/net/can/mcp251x.c                     | 10 +++++++--
 drivers/net/can/sja1000/sja1000_of_platform.c | 31 +++++++++++++--------------
 2 files changed, 23 insertions(+), 18 deletions(-)


