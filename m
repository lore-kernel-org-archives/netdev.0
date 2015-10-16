From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 0/2] net: hns: fixes two bugs in hns driver
Date: Fri, 16 Oct 2015 17:03:18 +0800
Message-ID: <1444986200-39566-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>,
	<chenny.xu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This patchset fixes two bugs in hns driver.
  - fixes timeout when received pause frame from the connective ports
  - should be set by using ethtool -s when the devices are link down

Chenny Xu (1):
  net: hns: fixes the issue by using ethtool -s

lisheng (1):
  net: hns: fixes a bug about timeout by pause frame

 drivers/net/ethernet/hisilicon/hns/hns_enet.c    | 13 ++++----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 39 ++++++++----------------
 2 files changed, 18 insertions(+), 34 deletions(-)

-- 
1.9.1
