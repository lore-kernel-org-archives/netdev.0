From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: hns: add function declarations in hns_dsaf_mac.h
Date: Sun, 18 Sep 2016 17:11:36 +0800
Message-ID: <1474189896-20417-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35189 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754464AbcIRJLw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 05:11:52 -0400
Received: by mail-pf0-f171.google.com with SMTP id z123so40866075pfz.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 02:11:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c:246:6: warning: no previous prototype for 'hns_dsaf_srst_chns' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c:276:6: warning: no previous prototype for 'hns_dsaf_roce_srst' [-Wmissing-prototypes]

In fact, these two functions are not declared in any file, but should
be declared in a header file, thus can be recognized in other file.

So this patch adds the declarations into
drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 4cbdf14..31f6505 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -462,4 +462,6 @@ int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 			enum hnae_led_state status);
 void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en);
 
+void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool dereset);
+void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool dereset);
 #endif /* _HNS_DSAF_MAC_H */
-- 
2.7.4
