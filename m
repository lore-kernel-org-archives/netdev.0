From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH net-next 3/6] arcnet: com20020-pci: set dev_port to the subdevice index
Date: Wed, 21 Oct 2015 17:45:29 +0200
Message-ID: <1445442332-10625-4-git-send-email-m.grzeschik@pengutronix.de>
References: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52071 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbJUPpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:45:45 -0400
In-Reply-To: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the dev_port according to the index of
the card. This can be used by udev to name the ports
in userspace.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index a12bf83..e3b7c14e 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -96,6 +96,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 			ret = -ENOMEM;
 			goto out_port;
 		}
+		dev->dev_port = i;
 
 		dev->netdev_ops = &com20020_netdev_ops;
 
-- 
2.6.1
