From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 0/7] net: hns: fix some bugs in HNS driver
Date: Thu, 24 Mar 2016 19:07:59 +0800
Message-ID: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41732 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089AbcCXKt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 06:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some bug fixed patches for HNS driver.

They are:

>from Kejian, fix for the warning of passing zero to 'PTR_ERR'

>from qianqian, four fixes for inappropriate operation in hns driver

>from Sheng, one fix for optimization of irq proccess in hns driver, and
one fix for hilink status for hns driver.

For more details, please see individual patches.

MBR.

Kejian Yan (1):
  net: hns: fix warning of passing zero to 'PTR_ERR'

Qianqian Xie (4):
  net: hns: fix a bug for cycle index
  net: hns: optimizate fmt of snprintf()
  net: hns: bug fix for return values
  net: hns: remove useless variable assignment and comment

Sheng Li (2):
  net: hns: optimizate irq proccess for HNS V2
  net: hns: bug fix about getting hilink status for HNS v2

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 +++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 40 ++++++++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 16 ++++-----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  4 +--
 6 files changed, 41 insertions(+), 36 deletions(-)

-- 
1.9.1
