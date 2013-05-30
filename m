From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 4/7] net, jme: remove redundant D0 power state set
Date: Thu, 30 May 2013 18:22:43 +0800
Message-ID: <1369909363-38612-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:34742 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab3E3KXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pci_enable_device() will set device power state to D0,
so it's no need to do it again in jme_init_one().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/jme.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 070a6f1..7fbe6ab 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3148,7 +3148,6 @@ jme_init_one(struct pci_dev *pdev,
 	jme->mii_if.mdio_write = jme_mdio_write;
 
 	jme_clear_pm(jme);
-	pci_set_power_state(jme->pdev, PCI_D0);
 	device_set_wakeup_enable(&pdev->dev, true);
 
 	jme_set_phyfifo_5level(jme);
-- 
1.7.1
