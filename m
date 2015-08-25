From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-08-25
Date: Tue, 25 Aug 2015 08:55:45 +0200
Message-ID: <1440485746-28027-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49502 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbHYGzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 02:55:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is the updated pull request of one patch by me for the peak_usb driver. It
fixes the driver, so that non FD adapters don't provide CAN FD bittimings.

regards,
Marc

---

The following changes since commit b6df7d61c8776a882dd47ba4714d1445dd7ef2d9:

  net: bcmgenet: fix uncleaned dma flags (2015-08-23 23:00:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.2-20150825

for you to fetch changes up to 06b23f7fbbf26a025fd68395c7586949db586b47:

  can: pcan_usb: don't provide CAN FD bittimings by non-FD adapters (2015-08-25 08:50:00 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.2-20150825

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: pcan_usb: don't provide CAN FD bittimings by non-FD adapters

 drivers/net/can/usb/peak_usb/pcan_usb.c      | 24 +++----
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  4 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |  4 +-
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c   | 96 +++++++++++++++-------------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  | 24 +++----
 5 files changed, 82 insertions(+), 70 deletions(-)
