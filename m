From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 19/26] ixgb: convert dev->priv to netdev_priv(dev).
Date: Tue, 29 Aug 2006 09:44:57 -0700
Message-ID: <20060829164457.6872.89149.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:51466 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965094AbWH2Qgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:43 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6959735..fee4c5a 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2190,7 +2190,7 @@ ixgb_restore_vlan(struct ixgb_adapter *a
 
 static void ixgb_netpoll(struct net_device *dev)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(dev);
 
 	disable_irq(adapter->pdev->irq);
 	ixgb_intr(adapter->pdev->irq, dev, NULL);



---
Auke Kok <auke-jan.h.kok@intel.com>
