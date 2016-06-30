From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 0/9] net: hns: fix the typo of hns
Date: Thu, 30 Jun 2016 15:25:00 +0800
Message-ID: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series includes typo fixes which review by Andy, adding
the hns maintainer to MAINTAINERS, as below:

 > from Daode: adds the maintainer for hns driver;

 > from Daode: fix the typo of hns reviewed by Andy Shevchenko;

 > from Kejian: one remove redundant function and two fix to get 
configuration from DT.

changlog:
 v1 -> v2:
  fix the indentations reviewed by David.

Daode Huang (6):
  MAINTAINERS: add maintainers for hns driver
  net: hns: fix code style about hns driver
  net: hns: change code style from a = a + x to a += x
  net: hns: delete redundant parens
  net: hns: add a space before "*/"
  net: hns: normalize two different loop

Kejian Yan (3):
  net: hns: remove redundant hns_mac_dev_to_enet_if()
  net: hns: add media-type property for hns
  net: hns: get reset registers from DT

 MAINTAINERS                                        |  9 +++
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  9 +++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 41 +++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 52 +++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 16 ++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  4 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 14 +++-
 drivers/net/ethernet/hisilicon/hns_mdio.c          | 80 ++++++++++++++++++----
 10 files changed, 158 insertions(+), 69 deletions(-)

-- 
1.9.1
