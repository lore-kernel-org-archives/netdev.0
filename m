From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-12-07
Date: Sun,  7 Dec 2014 23:06:03 +0100
Message-ID: <1417989966-31309-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58587 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbaLGWGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 17:06:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of three patches by Stephane Grosjean which fix several
bugs in the peak_usb CAN drivers.

Please queue, if possible for 3.18, if it's too late these patches takes the
slow lane via net-next.

regards,
Marc

---

The following changes since commit f2a01517f2a1040a0b156f171a7cefd748f2fd03:

  openvswitch: Fix flow mask validation. (2014-12-05 21:42:16 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.18-20141207

for you to fetch changes up to 62bc24f67abda56e486735706be6a4dea60fdb4c:

  can: peak_usb: fix multi-byte values endianess (2014-12-07 21:04:03 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.18-20141207

----------------------------------------------------------------
Stephane Grosjean (3):
      can: peak_usb: fix memset() usage
      can: peak_usb: fix cleanup sequence order in case of error during init
      can: peak_usb: fix multi-byte values endianess

 drivers/net/can/usb/peak_usb/pcan_usb.c      | 14 ++++----
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 20 +++++++-----
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  | 23 +++++++------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h  | 48 ++++++++++++++--------------
 4 files changed, 54 insertions(+), 51 deletions(-)
