From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] ne2k-pci: use dev->addr_len instead of "6"
Date: Sun, 3 May 2009 11:55:06 +0200
Message-ID: <20090503095506.GA6177@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, lkundrak@v3.sk, jeff@garzik.org,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37723 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbZECJ4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2009 05:56:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spotted a tiny ugliness in a recently posted patch. This patch cuts it out.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/ne2k-pci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index 7d83896..3fcebb7 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -374,7 +374,7 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &ne2k_pci_ethtool_ops;
 	NS8390_init(dev, 0);
 
-	memcpy(dev->dev_addr, SA_prom, 6);
+	memcpy(dev->dev_addr, SA_prom, dev->addr_len);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	i = register_netdev(dev);
