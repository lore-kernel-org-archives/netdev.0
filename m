From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 00/10] net: hns: bugs fixed for hns
Date: Mon, 21 Mar 2016 19:06:31 +0800
Message-ID: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<xieqianqian@huawei.com>, <andrew@lunn.ch>, <ivecera@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:20314 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757AbcCUKsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 06:48:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes some bug fixes and updates for hns driver.

>from Daode, one fix about mss.

>from Kejian, one fix about ping6 issue, one fix about mac address setting,
two fix for RSS setting, two fix about mtu setting.

>from qianqian, fixed HNS v2 xge statistic reg issue.

>from Sheng, one fix about manage packets sending, one fix about GMACs mac
setting.

For more details, please see individual patches.

Thanks a lot!

Daode Huang (1):
  net: hns: bug fix about the overflow of mss

Kejian Yan (6):
  net: hns: bug fix about ping6
  net: hns: add uc match for debug ports
  net: hns: fix return value of the function about rss
  net: hns: fixes a bug of RSS
  net: hns: fix the bug about mtu setting
  net: hns: adds limitation for debug port mtu

Qianqian Xie (1):
  net: hns: set xge statistic reg as read only

Sheng Li (2):
  net: hns: fixed portid bug in sending manage pkt
  net: hns: fixed the bug about GMACs mac setting

 drivers/net/ethernet/hisilicon/hns/hnae.h          |  3 ++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 12 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 40 +++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 18 +++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  4 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  5 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  5 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |  2 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 32 +++++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 42 ++++++++++++----------
 11 files changed, 123 insertions(+), 42 deletions(-)

-- 
1.9.1
