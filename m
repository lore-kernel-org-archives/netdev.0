From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 3/7] net: hns3: Cleanup indentation for Kconfig in the the hisilicon folder
Date: Mon, 9 Oct 2017 15:43:57 +0800
Message-ID: <1507535041-204956-4-git-send-email-linyunsheng@huawei.com>
References: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a few indentation for Kconfig file in the
hisilicon folder.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/Kconfig | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 9d7cb03..30000b6 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -78,7 +78,7 @@ config HNS_ENET
 
 config HNS3
 	tristate "Hisilicon Network Subsystem Support HNS3 (Framework)"
-    depends on PCI
+	depends on PCI
 	---help---
 	  This selects the framework support for Hisilicon Network Subsystem 3.
 	  This layer facilitates clients like ENET, RoCE and user-space ethernet
@@ -87,7 +87,7 @@ config HNS3
 
 config HNS3_HCLGE
 	tristate "Hisilicon HNS3 HCLGE Acceleration Engine & Compatibility Layer Support"
-    depends on PCI_MSI
+	depends on PCI_MSI
 	depends on HNS3
 	---help---
 	  This selects the HNS3_HCLGE network acceleration engine & its hardware
@@ -96,7 +96,7 @@ config HNS3_HCLGE
 
 config HNS3_ENET
 	tristate "Hisilicon HNS3 Ethernet Device Support"
-    depends on 64BIT && PCI
+	depends on 64BIT && PCI
 	depends on HNS3 && HNS3_HCLGE
 	---help---
 	  This selects the Ethernet Driver for Hisilicon Network Subsystem 3 for hip08
-- 
1.9.1
