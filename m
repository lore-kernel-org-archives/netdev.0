From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-10-04
Date: Thu,  4 Oct 2012 19:57:19 +0200
Message-ID: <1349373442-11128-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here are three patches for the v3.7 release cycle. Two patches by Peter Senna
Tschudin which fix the return values in the error handling path of the sja1000
peak pci and pcmcia driver. And one patch by myself that fixes a compile
breakage of the mpc5xxx_can mscan driver due to a section conflict.

I'm resending this pull-reqeust because I messed up the netdev mailinglist
address in my last posting. Sorry for the noise :)

regards,
Marc

---

The following changes since commit c0b8b99287235626a5850ef7e5bfc842d1ebcecd:

  cxgb4: Fix build error due to missing linux/vmalloc.h include. (2012-10-03 20:50:08 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.7

for you to fetch changes up to 8cf437a0dc2acacb4efa5eb73af9067bba3d2232:

  can: mpc5xxx_can: fix section type conflict (2012-10-04 19:26:32 +0200)

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: mpc5xxx_can: fix section type conflict

Peter Senna Tschudin (2):
      can: peak_pci: fix error return code
      can: peak_pcmcia: fix error return code

 drivers/net/can/mscan/mpc5xxx_can.c   |    8 ++++----
 drivers/net/can/sja1000/peak_pci.c    |    2 ++
 drivers/net/can/sja1000/peak_pcmcia.c |    4 +++-
 3 files changed, 9 insertions(+), 5 deletions(-)


