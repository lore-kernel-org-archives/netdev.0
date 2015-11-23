From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-11-23
Date: Mon, 23 Nov 2015 09:46:51 +0100
Message-ID: <1448268414-18583-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43257 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760AbbKWIrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 03:47:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of three patches for the upcoming v4.4 release.

The first patch is by Mirza Krak, it fixes a problem with the sja1000 driver
after resuming from suspend to disk, by clearing all outstanding interrupts.
Oliver Hartkopp contributes two patches targeting almost all driver, they fix
the assignment of the error location in CAN error messages.

regards,
Marc

---

The following changes since commit 4c6980462f32b4f282c5d8e5f7ea8070e2937725:

  net: ip6mr: fix static mfc/dev leaks on table destruction (2015-11-22 20:44:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.4-20151123

for you to fetch changes up to a2ec19f888f1fb06e2424486423a16f86ad1fcc4:

  can: remove obsolete assignment for CAN protocol error type (2015-11-23 09:37:38 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.4-20151123

----------------------------------------------------------------
Mirza Krak (1):
      can: sja1000: clear interrupts on start

Oliver Hartkopp (2):
      can: fix assignment of error location in CAN error messages
      can: remove obsolete assignment for CAN protocol error type

 drivers/net/can/bfin_can.c        |  2 --
 drivers/net/can/c_can/c_can.c     |  7 ++-----
 drivers/net/can/cc770/cc770.c     |  2 +-
 drivers/net/can/flexcan.c         |  4 ++--
 drivers/net/can/janz-ican3.c      |  1 -
 drivers/net/can/m_can/m_can.c     |  7 ++-----
 drivers/net/can/pch_can.c         |  3 +--
 drivers/net/can/rcar_can.c        | 11 +++++------
 drivers/net/can/sja1000/sja1000.c |  4 +++-
 drivers/net/can/sun4i_can.c       |  1 -
 drivers/net/can/ti_hecc.c         |  7 ++-----
 drivers/net/can/usb/ems_usb.c     |  1 -
 drivers/net/can/usb/esd_usb2.c    |  1 -
 drivers/net/can/usb/kvaser_usb.c  |  5 ++---
 drivers/net/can/usb/usb_8dev.c    |  4 +---
 drivers/net/can/xilinx_can.c      |  9 +++------
 16 files changed, 24 insertions(+), 45 deletions(-)
