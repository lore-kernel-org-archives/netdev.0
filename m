From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 01/21] com20020-pci: add dev_port for udev handling
Date: Fri, 24 Apr 2015 19:20:35 +0200
Message-ID: <1429896055-31680-2-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44239 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031272AbbDXRWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:18 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
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
index 96edc13..9fa4eee 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -96,6 +96,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 			ret = -ENOMEM;
 			goto out_port;
 		}
+		dev->dev_port = i;
 
 		dev->netdev_ops = &com20020_netdev_ops;
 
-- 
2.1.4
