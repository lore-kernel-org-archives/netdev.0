From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH] net: hns: update the dependency
Date: Mon, 13 Jun 2016 16:56:20 +0800
Message-ID: <1465808180-193350-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <charles.chenxin@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <arnd@arndb.de>,
	<paul.gortmaker@windriver.com>, <k.kozlowski@samsung.com>,
	<geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

After the patchset about adding support of ACPI (commit id is 6343488)
being applied, HNS does not depend on OF. It depends on OF or ACPI, so
the Kconfig file needs to be updated.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 4ccc032..2e25662 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_HISILICON
 	bool "Hisilicon devices"
 	default y
-	depends on OF && HAS_DMA
+	depends on (OF || ACPI) && HAS_DMA
 	depends on ARM || ARM64 || COMPILE_TEST
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
-- 
1.9.1
