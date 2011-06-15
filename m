From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH for 3.0-rc4 0/2] dp83640: bug fixes
Date: Wed, 15 Jun 2011 11:55:18 +0200
Message-ID: <cover.1308129342.git.richard.cochran@omicron.at>
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes two status frame related bugs in the driver for the
dp83640 phy. I am not sure whether you would call this a timer fix or
a networking fix, so I put both groups on CC.

Thanks,
Richard


Richard Cochran (2):
  dp83640: fix phy status frame event parsing
  dp83640: drop PHY status frames in the driver.

 drivers/net/phy/dp83640.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)
