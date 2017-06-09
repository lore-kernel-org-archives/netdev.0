From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-06-09
Date: Fri,  9 Jun 2017 14:55:07 +0200
Message-ID: <20170609125513.24436-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of 6 patches for net/master.

There's a patch by Stephane Grosjean that fixes an uninitialized symbol warning
in the peak_canfd driver. A patch by Johan Hovold to fix the product-id
endianness in an error message in the the peak_usb driver. A patch by Oliver
Hartkopp to enable CAN FD for virtual CAN devices by default. Three patches by
me, one makes the helper function can_change_state() robust to be called with
cf == NULL. The next patch fixes a memory leak in the gs_usb driver. And the
last one fixes a lockdep splat by properly initialize the per-net
can_rcvlists_lock spin_lock.

The following changes since commit 097d3c9508dc58286344e4a22b300098cf0c1566:

  net: vrf: Make add_fib_rules per network namespace flag (2017-06-08 19:27:42 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.12-20170609

for you to fetch changes up to 97edec3a11cf6f73f2e45c3035b5ff8e4c3543dd:

  can: enable CAN FD for virtual CAN devices by default (2017-06-09 14:39:02 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.12-20170609

----------------------------------------------------------------
Johan Hovold (1):
      can: peak_usb: fix product-id endianness in error message

Marc Kleine-Budde (3):
      can: dev: make can_change_state() robust to be called with cf == NULL
      can: gs_usb: fix memory leak in gs_cmd_reset()
      can: af_can: namespace support: fix lockdep splat: properly initialize spin_lock

Oliver Hartkopp (1):
      can: enable CAN FD for virtual CAN devices by default

Stephane Grosjean (1):
      can: peak_canfd: fix uninitialized symbol warnings

 drivers/net/can/dev.c                        | 3 +++
 drivers/net/can/peak_canfd/peak_canfd.c      | 2 +-
 drivers/net/can/usb/gs_usb.c                 | 2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 4 +---
 drivers/net/can/vcan.c                       | 2 +-
 drivers/net/can/vxcan.c                      | 2 +-
 net/can/af_can.c                             | 3 +--
 7 files changed, 10 insertions(+), 8 deletions(-)


