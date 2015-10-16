From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 3/6] arcnet: com20020-pci: set dev_port to the subdevice index
Date: Fri, 16 Oct 2015 13:00:57 +0200
Message-ID: <1444993260-9667-4-git-send-email-m.grzeschik@pengutronix.de>
References: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45567 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932223AbbJPLBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 07:01:14 -0400
In-Reply-To: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
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
