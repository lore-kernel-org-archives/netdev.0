From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next] hinic: don't build the module by default
Date: Mon, 28 Aug 2017 15:16:05 +0200
Message-ID: <20170828131605.3173-1-vkuznets@redhat.com>
Cc: Aviad Krawczyk <aviad.krawczyk@huawei.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We probably don't want to enable code supporting particular hardware by
default e.g. when someone does 'make defconfig'. Other ethernet modules
don't do it.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/ethernet/huawei/hinic/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/huawei/hinic/Kconfig b/drivers/net/ethernet/huawei/hinic/Kconfig
index 69f2b1fba48d..08db24954f7e 100644
--- a/drivers/net/ethernet/huawei/hinic/Kconfig
+++ b/drivers/net/ethernet/huawei/hinic/Kconfig
@@ -5,7 +5,6 @@
 config HINIC
 	tristate "Huawei Intelligent PCIE Network Interface Card"
 	depends on (PCI_MSI && X86)
-	default m
 	---help---
 	  This driver supports HiNIC PCIE Ethernet cards.
 	  To compile this driver as part of the kernel, choose Y here.
-- 
2.13.5
