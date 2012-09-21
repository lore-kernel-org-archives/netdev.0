From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-09-21
Date: Fri, 21 Sep 2012 13:05:33 +0200
Message-ID: <1348225535-24976-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

two patches for the v3.6 release cycle. Ira W. Snyder fixed support for the
older version of the Janz CMOD-IO Carrier Board. I found and fixed an oops in
the ti_hecc driver, which occurs when removing the module if the network
interface is still open.

If it's too late for these patches, I'll rebase them to net-next.
 
regards, Marc

--

The following changes since commit c0d680e577ff171e7b37dbdb1b1bf5451e851f04:

  net: do not disable sg for packets requiring no checksum (2012-09-20 22:23:40 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.6

for you to fetch changes up to ab04c8bd423edb03e2148350a091836c196107fc:

  can: ti_hecc: fix oops during rmmod (2012-09-21 12:54:53 +0200)

----------------------------------------------------------------
Ira W. Snyder (1):
      can: janz-ican3: fix support for older hardware revisions

Marc Kleine-Budde (1):
      can: ti_hecc: fix oops during rmmod

 drivers/net/can/janz-ican3.c |    4 +---
 drivers/net/can/ti_hecc.c    |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)


