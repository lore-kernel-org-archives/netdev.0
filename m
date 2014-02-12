From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-02-12
Date: Wed, 12 Feb 2014 11:35:39 +0100
Message-ID: <1392201340-6909-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35988 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbaBLKfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 05:35:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request with one patch for net/master, for the current release
cycle. Olivier Sobrie noticed and fixed that the kvaser_usb driver doesn't
check the number of channels value from the hardware, which may result in
writing over the bounds of an array in the driver.

regards,
Marc

---

The following changes since commit 738b52bb9845da183b6ff46a8f685b56a63379d1:

  Merge tag 'microblaze-3.14-rc3' of git://git.monstr.eu/linux-2.6-microblaze (2014-02-11 12:24:35 -0800)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.14-20140212

for you to fetch changes up to 862474f8b46f6c1e600d4934e40ba40646c696ec:

  can: kvaser_usb: check number of channels returned by HW (2014-02-12 10:42:02 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.14-20140212

----------------------------------------------------------------
Olivier Sobrie (1):
      can: kvaser_usb: check number of channels returned by HW

 drivers/net/can/usb/kvaser_usb.c | 2 ++
 1 file changed, 2 insertions(+)
