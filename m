From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH V2 net 2/4] net: hns: bug fix for format string
Date: Fri, 11 Mar 2016 18:20:20 +0800
Message-ID: <1457691622-124657-3-git-send-email-lisheng011@huawei.com>
References: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63295 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcCKKK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:10:28 -0500
In-Reply-To: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

There is not a format string in function snprinf().
This patch will fix it.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index b8517b0..d0591d9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -641,7 +641,8 @@ static void hns_gmac_get_strings(u32 stringset, u8 *data)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(g_gmac_stats_string); i++) {
-		snprintf(buff, ETH_GSTRING_LEN, g_gmac_stats_string[i].desc);
+		snprintf(buff, ETH_GSTRING_LEN, "%s",
+			g_gmac_stats_string[i].desc);
 		buff = buff + ETH_GSTRING_LEN;
 	}
 }
-- 
1.9.1
