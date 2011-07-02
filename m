From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] net: 8139too: Initial necessary vlan_features to support
 vlan
Date: Sat, 02 Jul 2011 16:06:44 +0800
Message-ID: <4E0ED194.2030103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52072 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab1GBIFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jul 2011 04:05:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Offload setting of vlan device requires
vlan_features to be initialed.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/8139too.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index ed6355c..c2672c6 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -993,6 +993,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	 * features
 	 */
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+	dev->vlan_features = dev->features;
 
 	dev->irq = pdev->irq;
 
-- 
1.7.4.1
