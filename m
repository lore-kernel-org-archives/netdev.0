From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 1/2] 3c59x/net: Use dev_is_pci() to simplify code
Date: Thu, 5 Dec 2013 19:37:38 +0800
Message-ID: <1386243458-32576-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Yijing Wang <wangyijing@huawei.com>,
	Hanjun Guo <guohanjun@huawei.com>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:10323 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936Ab3LELju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 06:39:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard PCI macro dev_is_pci() to simplify code.

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
