From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 2/2] net: hns: add missing function declaration
Date: Fri, 30 Sep 2016 15:41:55 +0800
Message-ID: <1475221315-18602-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        baoyou.xie@linaro.org, xie.baoyou@zte.com.cn, han.fei@zte.com.cn,
        tang.qiang007@zte.com.cn
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, huangdaode@hisilicon.com,
        lisheng011@huawei.com, xieqianqian@huawei.com, fabf@skynet.be,
        oulijun@huawei.com, arnd@arndb.de, vinod.koul@intel.com,
        lipeng321@huawei.com, andrew@lunn.ch, tremyfr@gmail.com,
        chenny.xu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:2784:5: warning: no previous prototype for 'hns_dsaf_roce_reset' [-Wmissing-prototypes]

In fact, this function is not declared in any file, but should be
declared in a header file. thus can be recognized in other file.

so this patch adds the missing function declaration into
drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index f3681d5..c655ecb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -449,7 +449,10 @@ void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable);
 
 void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable);
 
+int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
+
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
+
 void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
 void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 inode_num);
-- 
2.7.4
