From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-07-19
Date: Fri, 19 Jul 2013 15:17:47 +0200
Message-ID: <1374239869-27085-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, linux-can@vger.kernel.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42808 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760254Ab3GSNSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here are two fixes for the v3.11 release cycle:

Maximilian Schneider contributes a patch for the esd_usb2 CAN driver. It adds
sanity checking to the data coming from the USB CAN adapter before using it.
Alexey Khoroshilov from the Linux Driver Verification project fixes an urb leak
in the error handling of the USB 8dev's usb_8dev_start() function.

regards,
Marc
---

The following changes since commit ecb2cf1a6b63825a258ff4fe0d7f3070fbe4676b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-07-18 20:08:47 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git fixes-for-3.11

for you to fetch changes up to 7671986839f9207f8d76e8ef92b2d3f263a794cc:

  can: usb_8dev: fix urb leak on failure path in usb_8dev_start() (2013-07-19 14:55:14 +0200)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      can: usb_8dev: fix urb leak on failure path in usb_8dev_start()

Maximilian Schneider (1):
      net: can: esd_usb2: check index of array before accessing

 drivers/net/can/usb/esd_usb2.c | 10 ++++++++++
 drivers/net/can/usb/usb_8dev.c |  1 +
 2 files changed, 11 insertions(+)
