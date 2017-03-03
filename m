From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-03-03
Date: Fri,  3 Mar 2017 14:55:31 +0100
Message-ID: <20170303135535.22937-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request for the upcoming v4.11 release.

There are two patches by Ethan Zonca for the gs_usb driver, the first one fixes
the memory used for USB transfers, the second one the coding style.

The last two patches are by me, one fixing a memory leak in the usb_8dev driver
the other a typo in the flexcan driver.

regards,
Marc

---

The following changes since commit 9f674e48c13dcbc31ac903433727837795b81efe:

  xen-netback: Use GFP_ATOMIC to allocate hash (2017-03-02 14:44:22 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.11-20170303

for you to fetch changes up to 66ddb82129df66a94219844c509074adb4330a28:

  can: flexcan: fix typo in comment (2017-03-03 13:00:07 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.11-20170303

----------------------------------------------------------------
Ethan Zonca (2):
      can: gs_usb: Don't use stack memory for USB transfers
      can: gs_usb: fix coding style

Marc Kleine-Budde (2):
      can: usb_8dev: Fix memory leak of priv->cmd_msg_buffer
      can: flexcan: fix typo in comment

 drivers/net/can/flexcan.c      |  2 +-
 drivers/net/can/usb/gs_usb.c   | 51 ++++++++++++++++++++++++++++--------------
 drivers/net/can/usb/usb_8dev.c |  9 +++-----
 3 files changed, 38 insertions(+), 24 deletions(-)

