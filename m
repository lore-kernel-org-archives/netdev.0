From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH v3 net-next 0/2] net: hns: get and set RSS indirection table by using ethtool
Date: Fri, 11 Mar 2016 11:25:45 +0800
Message-ID: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:46528 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbcCKDHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 22:07:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we use ethtool to retrieves or configure the receive flow hash 
indirection table, ethtool needs to call .get_rxnfc to get the ring number
so this patchset implements the .get_rxnfc and fixes the bug that we can
not get the tatal table each time.

---
change log:
PATCH v3:
 - This patchset fixes the building warning and error

PATCH v2:
 - This patchset fixes the comments provided by Andy Shevchenko <Andy Shevchenko>

PATCH v1:
 - first submit

Kejian Yan (2):
  net: hns: fix return value of the function about rss
  net: hns: fixes a bug of RSS

 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  8 ++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 28 ++++++++++++++++-------
 3 files changed, 26 insertions(+), 12 deletions(-)

-- 
1.9.1
