From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-02-26
Date: Fri, 26 Feb 2016 08:42:57 +0100
Message-ID: <1456472578-16272-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of one patch for net.

The patch by Maximilain Schneider fixes a kfree() problem during disconnect in
the gs_usb driver.

regrds,
Marc
---

The following changes since commit 4c0b6eaf373a5323f03a3a20c42fc435715b073d:

  net: thunderx: Fix for Qset error due to CQ full (2016-02-25 16:25:34 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.5-20160226

for you to fetch changes up to e9a2d81b1761093386a0bb8a4f51642ac785ef63:

  can: gs_usb: fixed disconnect bug by removing erroneous use of kfree() (2016-02-26 08:36:33 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.5-20160226

----------------------------------------------------------------
Maximilain Schneider (1):
      can: gs_usb: fixed disconnect bug by removing erroneous use of kfree()

 drivers/net/can/usb/gs_usb.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)


