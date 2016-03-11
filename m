From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH V2 net 0/4] net: hns: bugs fix about hns driver
Date: Fri, 11 Mar 2016 18:20:18 +0800
Message-ID: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63257 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcCKKKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:10:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

There is some inappropriate application of values in hns driver,
such as cycle index, returned value, format string, useless citation.
This patch set will solve it.

---
change log:
PATCH v2:
 - This patchset fixes the comments provided by Andy Shevchenko <Andy Shevchenko>

PATCH v1:
 - first submit

Qianqian Xie (4):
  net: hns: fix a bug for cycle index
  net: hns: bug fix for format string
  net: hns: bug fix for return values
  net: hns: remove useless head=ring->next_to_clean

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  3 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++------
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  5 +----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  4 ++--
 4 files changed, 11 insertions(+), 13 deletions(-)

-- 
1.9.1
