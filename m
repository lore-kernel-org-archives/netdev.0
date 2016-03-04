From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-03-04
Date: Fri,  4 Mar 2016 08:55:54 +0100
Message-ID: <1457078155-8479-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request for net/master.

There is one patch from Ed Spiridonov, which increases the performance of the
mcp251x SPI CAN driver, by avoiding to write to error flag register if it's
unnecessary.

regards,
Marc

---

The following changes since commit c1bb0a5588816ec26abc08aa9adcf90e32656781:

  be2net: don't enable multicast flag in be_enable_if_filters() routine (2016-03-03 17:18:03 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.5-20160304

for you to fetch changes up to d694b06c42a56c9610861ee0474b4d441af8ada6:

  can: mcp251x: avoid write to error flag register if it's unnecessary (2016-03-04 08:45:17 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.5-20160304

----------------------------------------------------------------
Ed Spiridonov (1):
      can: mcp251x: avoid write to error flag register if it's unnecessary

 drivers/net/can/spi/mcp251x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


