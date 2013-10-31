From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-10-31
Date: Thu, 31 Oct 2013 20:24:48 +0100
Message-ID: <1383247490-26984-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59167 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab3JaTZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 15:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I have two late fixes for the v3.12 release:

The first patch fixes a problem in the c_can's RX message handling, which can
lead to an endless interrupt loop under heavy load if messages are lost. The
second patch is by Olivier Sobrie and fixes the endpoint detection of the
kvaser_usb driver, which is needed for some devices.

regards,
Marc

---


The following changes since commit c17cb8b55b104c549aa20a72fa44141ad2c65ec2:

  doc:net: Fix typo in Documentation/networking (2013-10-30 17:10:20 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.12

for you to fetch changes up to 896e23bd04ea50a146dffd342e2f96180f0812a5:

  can: kvaser_usb: fix usb endpoints detection (2013-10-31 20:20:23 +0100)

----------------------------------------------------------------
Markus Pargmann (1):
      can: c_can: Fix RX message handling, handle lost message before EOB

Olivier Sobrie (1):
      can: kvaser_usb: fix usb endpoints detection

 drivers/net/can/c_can/c_can.c    |  6 +++---
 drivers/net/can/usb/kvaser_usb.c | 20 +++++++++++++-------
 2 files changed, 16 insertions(+), 10 deletions(-)
