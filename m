From: Bryan Wu <bryan.wu@canonical.com>
Subject: [PATCH 0/2] net-next/fec: bug fixing after introduced phylib supporting
Date: Fri,  7 May 2010 10:27:17 +0800
Message-ID: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>
To: davem@davemloft.net, Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After introduced phylib supporting, we found some critical issues in Ubuntu on
Freescale iMX51. Following 2 patches fix those bugs which was recorded in our
Launchpad bug tracker.

Bryan Wu (2):
  netdev/fec: fix performance impact from mdio poll operation
  netdev/fec: fix ifconfig eth0 down hang issue

 drivers/net/fec.c |   73 +++++++++++++++++++++++++++--------------------------
 1 files changed, 37 insertions(+), 36 deletions(-)
