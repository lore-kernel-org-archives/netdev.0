From: Otavio Salvador <otavio@ossystems.com.br>
Subject: [PATCH 2/2] net/natsami: store MAC into perm_addr
Date: Tue, 12 Apr 2011 12:30:41 -0300
Message-ID: <1302622241-11871-2-git-send-email-otavio@ossystems.com.br>
References: <1302622241-11871-1-git-send-email-otavio@ossystems.com.br>
Cc: Otavio Salvador <otavio@ossystems.com.br>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:59170 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab1DLPaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 11:30:55 -0400
Received: by gwaa18 with SMTP id a18so2389854gwa.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 08:30:55 -0700 (PDT)
In-Reply-To: <1302622241-11871-1-git-send-email-otavio@ossystems.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Otavio Salvador <otavio@ossystems.com.br>
---
 drivers/net/natsemi.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index aa2813e..1074231 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -860,6 +860,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 		prev_eedata = eedata;
 	}
 
+	/* Store MAC Address in perm_addr */
+	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
+
 	dev->base_addr = (unsigned long __force) ioaddr;
 	dev->irq = irq;
 
-- 
1.7.4.1

