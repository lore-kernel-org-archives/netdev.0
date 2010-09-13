From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/25] drivers/net/spider_net.c: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:51 -0700
Message-ID: <974ba2cf5b07b91ce307fd5b32af34f4c4a35e81.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/spider_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index cb6bcca..ece8d75 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -70,7 +70,7 @@ MODULE_PARM_DESC(rx_descriptors, "number of descriptors used " \
 MODULE_PARM_DESC(tx_descriptors, "number of descriptors used " \
 		 "in tx chain");
 
-char spider_net_driver_name[] = "spidernet";
+const char spider_net_driver_name[] = "spidernet";
 
 static DEFINE_PCI_DEVICE_TABLE(spider_net_pci_tbl) = {
 	{ PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_SPIDER_NET,
-- 
1.7.3.rc1
