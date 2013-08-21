From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 0/2] net: can: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 18:14:59 +0800
Message-ID: <1377080099-14552-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-can@vger.kernel.org>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <libo.chen@huawei.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_set_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Libo Chen (2):
  net: can: at91_can: use platform_set_drvdata()
  net: can: flexcan: use platform_set_drvdata()

 drivers/net/can/at91_can.c |    2 +-
 drivers/net/can/flexcan.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)


