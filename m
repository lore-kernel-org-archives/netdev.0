From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 1/3] be2net: Fix be_dev_family_check() return
 value check
Date: Wed, 1 Dec 2010 16:32:28 +0530
Message-ID: <20101201110228.GA1560@emulex.com>
Reply-To: Sathya Perla <sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37733 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753874Ab0LALCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 06:02:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 102567e..ca4bf9b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2899,7 +2899,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, adapter);
 
 	status = be_dev_family_check(adapter);
-	if (!status)
+	if (status)
 		goto free_netdev;
 
 	adapter->netdev = netdev;
-- 
1.6.5.2

