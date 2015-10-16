From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next v3 0/2] net: hisilicon fix some bugs in HNS drivers
Date: Fri, 16 Oct 2015 11:54:15 +0800
Message-ID: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>,
	<lipeng321@huawei.com>
To: <davem@davemloft.net>, <arnd@arndb.de>, <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes the two bugs in HNS driver, one is remove the hnae sysfs interface
according to the review comments from Arnd Bergmann <arnd@arndb.de>, another
is fixing the wrong mac_id judgement bug which is found during internal tests.

change log:
v3:
 remove the hnae sysfs interface.

v2:
  1) remove first bug fix, which is fixed in another patch submitted by
     Arnd Bergmann <arnd@arndb.de>
  2) change the code sytyle according to Joe.

v1:
 initial version.

huangdaode (2):
  net: hisilicon rm hnae sysfs interface
  net: hisilicon fix a bug on Hisilicon Network Subsystem

 drivers/net/ethernet/hisilicon/hns/hnae.c         | 47 -----------------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c |  2 +-
 2 files changed, 1 insertion(+), 48 deletions(-)

-- 
1.9.1
