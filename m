From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH net v2 2/2] 3c59x/net: Use dev_is_pci() instead of hardcoding
Date: Fri, 6 Dec 2013 14:34:55 +0800
Message-ID: <1386311695-22992-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Yijing Wang <wangyijing@huawei.com>,
	Hanjun Guo <guohanjun@huawei.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:8215 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab3LFGf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:35:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PCI standard macro dev_is_pci() instead of hardcoding.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/3com/3c59x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index ad5272b..af24c3c 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -693,7 +693,7 @@ DEFINE_WINDOW_IO(16)
 DEFINE_WINDOW_IO(32)
 
 #ifdef CONFIG_PCI
-#define DEVICE_PCI(dev) (((dev)->bus == &pci_bus_type) ? to_pci_dev((dev)) : NULL)
+#define DEVICE_PCI(dev) ((dev_is_pci(dev)) ? to_pci_dev((dev)) : NULL)
 #else
 #define DEVICE_PCI(dev) NULL
 #endif
-- 
1.7.1
