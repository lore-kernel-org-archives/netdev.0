From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH RESEND 0/5] Adopt pinctrl support for a few outstanding imx drivers
Date: Mon,  7 May 2012 08:53:55 +0800
Message-ID: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Dong Aisheng <dong.aisheng@linaro.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	spi-devel-general@lists.sourceforge.net,
	Grant Likely <grant.likely@secretlab.ca>,
	linux-i2c@vger.kernel.org, Wolfram Sang <w.sang@pengutronix.de>,
	linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-serial@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-serial-owner@vger.kernel.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With patch 5b3aa5f (pinctrl: add pinctrl_provide_dummies interface for
platforms to use) applied on pinctrl tree, and patch "ARM: imx: enable
pinctrl dummy states" [1] being there, we are ready to adopt pinctrl
API for imx drivers.  So let's start from a few outstanding ones.

I would expect to ask Arnd and Olof to pull pinctrl tree into arm-soc
as a dependency and then have series [1] and this patch set go through
arm-soc tree to ease the merge process.

Resend to have subsystem lists Cc-ed.

Regards,
Shawn

[1] http://thread.gmane.org/gmane.linux.kernel.mmc/14180

Shawn Guo (5):
  tty: serial: imx: adopt pinctrl support
  net: fec: adopt pinctrl support
  can: flexcan: adopt pinctrl support
  i2c: imx: adopt pinctrl support
  spi/imx: adopt pinctrl support

 drivers/i2c/busses/i2c-imx.c         |    8 ++++++++
 drivers/net/can/flexcan.c            |    6 ++++++
 drivers/net/ethernet/freescale/fec.c |    9 +++++++++
 drivers/spi/spi-imx.c                |    8 ++++++++
 drivers/tty/serial/imx.c             |    8 ++++++++
 5 files changed, 39 insertions(+), 0 deletions(-)

-- 
1.7.5.4

