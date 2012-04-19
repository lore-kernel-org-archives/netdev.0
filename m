From: mjr@cs.wisc.edu
Subject: [PATCH] ks8851: Fix request_irq/free_irq mismatch
Date: Thu, 19 Apr 2012 12:17:17 -0500
Message-ID: <1334855837-28366-1-git-send-email-mjr@cs.wisc.edu>
Cc: ben@simtec.co.uk, netdev@vger.kernel.org,
	Matt Renzelmann <mjr@cs.wisc.edu>
To: sboyd@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:32968 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707Ab2DSRUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 13:20:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Renzelmann <mjr@cs.wisc.edu>

The dev_id parameter passed to free_irq needs to match the one passed
to the corresponding request_irq.

Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
---

Resending -- forgot driver name in the title.  Sorry about that.

 drivers/net/ethernet/micrel/ks8851.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index e5dc075..a8b7d5b 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1524,7 +1524,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 
 
 err_netdev:
-	free_irq(ndev->irq, ndev);
+	free_irq(ndev->irq, ks);
 
 err_id:
 err_irq:
-- 
1.7.5.4
