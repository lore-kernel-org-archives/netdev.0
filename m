From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next 0/2] net: fix some bugs in HNS drivers
Date: Thu, 8 Oct 2015 14:17:23 +0800
Message-ID: <1444285045-23275-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes the two bugs in HNS driver, one is for fixing the
compilation warning bug on arm 32-bit platform, another is fixing the wrong
mac port judgement bug which is found during internal tests.

huangdaode (2):
  net: Fix Hisilicon Network Subsystem compilation warning
  net: fix a bug on Hisilicon Network Subsystem

 drivers/net/ethernet/hisilicon/hns/hnae.c         | 12 ++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

-- 
1.9.1
