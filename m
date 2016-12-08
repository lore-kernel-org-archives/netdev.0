From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-12-08
Date: Thu,  8 Dec 2016 16:35:51 +0100
Message-ID: <20161208153552.18122-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47933 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932115AbcLHPf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:35:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for one patch.

Jiho Chu found and fixed a use-after-free error in the cleanup path in the peak
pcan USB CAN driver.

regards,
Marc

---

The following changes since commit ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461:

  phy: Don't increment MDIO bus refcount unless it's a different owner (2016-12-07 13:27:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.9-20161208

for you to fetch changes up to b67d0dd7d0dc9e456825447bbeb935d8ef43ea7c:

  can: peak: fix bad memory access and free sequence (2016-12-08 15:59:52 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.9-20161208

----------------------------------------------------------------
추지호 (1):
      can: peak: fix bad memory access and free sequence

 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
