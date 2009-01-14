From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 12/34]bnx2x: Fixing the doorbell size
Date: Wed, 14 Jan 2009 18:43:17 +0200
Message-ID: <1231951397.11301.133.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763314AbZANQoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size of the doorbell is 4KB, this bug become visible when using more than 8
queues

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index a6c9d23..c1ba541 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -735,7 +735,7 @@ struct bnx2x {
 	struct bnx2x_fastpath	fp[MAX_CONTEXT];
 	void __iomem		*regview;
 	void __iomem		*doorbells;
-#define BNX2X_DB_SIZE		(16*2048)
+#define BNX2X_DB_SIZE		(16*BCM_PAGE_SIZE)
 
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
-- 
1.5.4.3




