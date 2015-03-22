From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-03-22
Date: Sun, 22 Mar 2015 20:13:31 +0100
Message-ID: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull-request of 7 patches for net/master.

Ahmed S. Darwish fixes another two problems in the kvaser_usb driver. A patch
by Colin Ian King for the gs_usb driver adds a missing check for kzalloc
allocation failures. Two patches by Stephane Grosjean for the peak_usb driver
add missing support for ISO / non-ISO mode switching. Andri Yngvason
contributes a patch to fix the state handling in the flexcan driver. The last
patch by Andreas Werner for the flexcan driver add missing EPROBE_DEFER
handling for the transceiver regulator.

regards,
Marc
---

The following changes since commit f40bff4239d45ac061044a8a79cf6868c62df345:

  cx82310_eth: wait for firmware to become ready (2015-03-21 18:23:19 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.0-20150322

for you to fetch changes up to 555828ef45f825d6ee06559f0304163550eed380:

  can: flexcan: Deferred on Regulator return EPROBE_DEFER (2015-03-22 19:20:10 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.0-20150322

----------------------------------------------------------------
Ahmed S. Darwish (2):
      can: kvaser_usb: Comply with firmware max tx URBs value
      can: kvaser_usb: Fix sparse warning __le16 degrades to integer

Andreas Werner (1):
      can: flexcan: Deferred on Regulator return EPROBE_DEFER

Andri Yngvason (1):
      can: flexcan: fix bus-off error state handling.

Colin Ian King (1):
      can: gs_usb: check for kzalloc allocation failure

Stephane Grosjean (2):
      can: peak_usb: rename usb option cmds definition and structs
      can: peak_usb_fd: add support for ISO / non-ISO mode switching

 drivers/net/can/flexcan.c                  | 18 +++++---
 drivers/net/can/usb/gs_usb.c               |  2 +
 drivers/net/can/usb/kvaser_usb.c           | 69 +++++++++++++++++-----------
 drivers/net/can/usb/peak_usb/pcan_ucan.h   | 15 +++---
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c | 73 ++++++++++++++++++++----------
 5 files changed, 113 insertions(+), 64 deletions(-)


