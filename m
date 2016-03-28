From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 0/2] net: hns: add setting coalescing parameters for HNS v2
Date: Mon, 28 Mar 2016 18:40:55 +0800
Message-ID: <1459161657-151406-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <charles.chenxin@huawei.com>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some different REGs about coalescing setting between HNS V2 and
HNS V1. The current HNS driver is only considering the situation for HNS
V1. It needs to support both of them. And Ethtool needs to know if it is
successful to set the parameters as well.

The patchset as below:

>from Lisheng, one fix about setting overtime regs, and the other is about
the return value from HW when setting the parameters.

Lisheng (2):
  net: hns: fixed the setting and getting overtime bug
  net: hns: set-coalesce-usecs returns errno by dsaf.ko

 drivers/net/ethernet/hisilicon/hns/hnae.h         |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  64 +++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 196 ++++++++++------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |  23 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |   1 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |   6 +-
 6 files changed, 133 insertions(+), 159 deletions(-)

-- 
1.9.1
