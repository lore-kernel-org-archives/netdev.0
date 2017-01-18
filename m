From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-01-18
Date: Wed, 18 Jan 2017 13:08:50 +0100
Message-ID: <20170118120852.6095-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33215 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751399AbdARMJf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 07:09:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master consisting of two patches.

In the first patch Einar Jón fixes a NULL-pointer-deref in the c_can_pci
driver. In the second patch Yegor Yefremov fixes the clock handling in the
ti_hecc driver.

regards,
Marc

---

The following changes since commit 93b43fd137cd8865adf9978ab9870a344365d3af:

  net: phy: dp83848: add DP83620 PHY support (2017-01-17 15:47:25 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.10-20170118

for you to fetch changes up to befa60113ce7ea270cb51eada28443ca2756f480:

  can: ti_hecc: add missing prepare and unprepare of the clock (2017-01-18 13:03:15 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.10-20170118

----------------------------------------------------------------
Einar Jón (1):
      can: c_can_pci: fix null-pointer-deref in c_can_start() - set device pointer

Yegor Yefremov (1):
      can: ti_hecc: add missing prepare and unprepare of the clock

 drivers/net/can/c_can/c_can_pci.c |  1 +
 drivers/net/can/ti_hecc.c         | 16 ++++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)
