From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-01-26
Date: Sat, 26 Jan 2013 17:33:24 +0100
Message-ID: <1359218007-18586-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a patch for net for the v3.8 release cycle. Olivier Sobrie found and
fixed a problem in the can error frame generation of three drivers (c_can,
pch_can and ti_hecc).

regards,
Marc

---

The following changes since commit 5d0feaff230c0abfe4a112e6f09f096ed99e0b2d:

  r8169: remove the obsolete and incorrect AMD workaround (2013-01-23 13:51:47 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.8

for you to fetch changes up to ee50e135aeb048b90fab662e661c58b67341830b:

  can: pch_can: fix invalid error codes (2013-01-26 17:13:41 +0100)

----------------------------------------------------------------
Olivier Sobrie (3):
      can: c_can: fix invalid error codes
      can: ti_hecc: fix invalid error codes
      can: pch_can: fix invalid error codes

 drivers/net/can/c_can/c_can.c |    4 ++--
 drivers/net/can/pch_can.c     |    2 +-
 drivers/net/can/ti_hecc.c     |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)


