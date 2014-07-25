From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-07-25
Date: Fri, 25 Jul 2014 09:36:49 +0200
Message-ID: <1406273810-19116-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of one patch for the net tree, hoping to get into the
3.16 release.

The patch by George Cherian fixes a regression in the c_can platform driver.
When using two interfaces the regression leads to a non function second
interface.

regards,
Marc

---

The following changes since commit 15ba2236f3556fc01b9ca91394465152b5ea74b6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-07-21 22:46:01 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.16-20140725

for you to fetch changes up to 33cf75656923ff11d67a937a4f8e9344f58cea77:

  can: c_can_platform: Fix raminit, use devm_ioremap() instead of devm_ioremap_resource() (2014-07-25 09:23:08 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.16-20140725

----------------------------------------------------------------
George Cherian (1):
      can: c_can_platform: Fix raminit, use devm_ioremap() instead of devm_ioremap_resource()

 drivers/net/can/c_can/c_can_platform.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
