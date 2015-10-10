From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next] net: hns: fix the unknown phy_nterface_t type error
Date: Sat, 10 Oct 2015 17:20:38 +0800
Message-ID: <1444468838-59313-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the building error reported by Jiri Pirko <jiri@resnulli.us>

drivers/net/ethernet/hisilicon/hns/hnae.h:465:2: error: unknown type
name 'phy_interface_t'
        phy_interface_t phy_if;
	^
the full build log is on https://lists.01.org/pipermail/kbuild-all.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 5edd8cd..d4a1eb1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
+#include <linux/phy.h>
 #include <linux/types.h>
 
 #define HNAE_DRIVER_VERSION "1.3.0"
-- 
1.9.1
