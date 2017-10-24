From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-10-24
Date: Tue, 24 Oct 2017 13:27:22 +0200
Message-ID: <20171024112725.13203-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:44105 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932196AbdJXL1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 07:27:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here's another pull request for net/master.

The patch by Gerhard Bertelsmann fixes the CAN_CTRLMODE_LOOPBACK in the
sun4i driver. Two patches by Jimmy Assarsson for the kvaser_usb driver
fix a print in the error path of the kvaser_usb_close() and remove a
wrong warning message with the Leaf v2 firmware version v4.1.844.

regards,
Marc

---

The following changes since commit b71d21c274eff20a9db8158882b545b141b73ab8:

  sctp: full support for ipv6 ip_nonlocal_bind & IP_FREEBIND (2017-10-24 18:39:46 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.14-20171024

for you to fetch changes up to e1d2d1329a5722dbecc9c278303fcc4aa01f8790:

  can: kvaser_usb: Ignore CMD_FLUSH_QUEUE_REPLY messages (2017-10-24 13:00:36 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.14-20171024

----------------------------------------------------------------
Gerhard Bertelsmann (1):
      can: sun4i: fix loopback mode

Jimmy Assarsson (2):
      can: kvaser_usb: Correct return value in printout
      can: kvaser_usb: Ignore CMD_FLUSH_QUEUE_REPLY messages

 drivers/net/can/sun4i_can.c      | 3 +--
 drivers/net/can/usb/kvaser_usb.c | 9 ++++++++-
 2 files changed, 9 insertions(+), 3 deletions(-)
