From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 0/6]net: hns: hns driver updates
Date: Fri, 4 Mar 2016 09:09:52 +0800
Message-ID: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:10800 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456AbcCDAvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:51:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
This patch series are hisilicon network driver bug fix.

Best Regards
Daode.

Daode Huang (5):
  net: hns: bug fix about the overflow of mss
  net: hns: fixes the hw interrupt bug in using napi
  net: hns: fixed portid bug in sending manage pkt
  net: hns: adds uc match for debug port
  net: hns: bug fix of getting hilink status

Lisheng (1):
  net: hns: fixed service-ges setting MAC-addr bug

 drivers/net/ethernet/hisilicon/hns/hnae.h          |  3 ++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 29 ++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 39 +++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  4 +++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 30 +++++++++--------
 6 files changed, 67 insertions(+), 39 deletions(-)

-- 
1.9.1
