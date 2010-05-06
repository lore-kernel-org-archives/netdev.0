From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] e1000e: Save irq into netdev structure
Date: Wed, 05 May 2010 17:03:32 -0700
Message-ID: <20100506000330.8042.91540.stgit@localhost.localdomain>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Tom Herbert <therbert@google.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:53498 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754731Ab0EFAEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 20:04:22 -0400
In-Reply-To: <20100506000221.8042.64794.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Set net->devirq to pdev->irq.  This should be consistent with other
drivers.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b767dbb..c5f65a2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5456,6 +5456,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
+	netdev->irq = pdev->irq;
+
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
 	hw = &adapter->hw;

