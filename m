From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-01-21
Date: Wed, 21 Jan 2015 22:46:30 +0100
Message-ID: <1421876791-31014-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request for v3.19, net/master, which consists of a single patch.

Viktor Babrian fixes the issue in the c_can dirver, that the CAN interface
might continue to send frames after the interface has been shut down.

regards,
Marc

---

The following changes since commit 06efe0e54018cb19cf0807447dc3ac747ffcfd1c:

  Merge tag 'pinctrl-v3.19-3' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl (2015-01-20 21:23:41 +1200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-3.19-20150121

for you to fetch changes up to 7ffd7b4e169d619e66928fe5d997723f2c6f1056:

  can: c_can: end pending transmission on network stop (ifdown) (2015-01-21 22:43:14 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.19-20150121

----------------------------------------------------------------
Viktor Babrian (1):
      can: c_can: end pending transmission on network stop (ifdown)

 drivers/net/can/c_can/c_can.c | 3 +++
 1 file changed, 3 insertions(+)

