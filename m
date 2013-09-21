From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-09-21
Date: Sat, 21 Sep 2013 16:08:12 +0200
Message-ID: <1379772493-7856-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36727 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab3IUOIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 10:08:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here is a fixes for the v3.12 release cycle. Alexey Khoroshilov from the Linux
Driver Verification project submitted a patch that fixes a memory leak in the
failure paths of the peak USB driver.


regards,
Marc

---

The following changes since commit dcb30e659287a6b40dafed1362532da42ec27229:

  Merge tag 'arm64-stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64 (2013-09-20 08:18:51 -0500)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git fixes-for-3.12

for you to fetch changes up to f37d6e701f2a3a04e66690397340a6417f6e053f:

  can: pcan_usb_core: fix memory leak on failure paths in peak_usb_start() (2013-09-20 20:58:21 +0200)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      can: pcan_usb_core: fix memory leak on failure paths in peak_usb_start()

 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)
