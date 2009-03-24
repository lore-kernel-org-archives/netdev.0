From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: [PATCH] macb: fix warning "warning: unused variable `dev' "
Date: Tue, 24 Mar 2009 11:26:42 +0100
Message-ID: <1237890402-19133-1-git-send-email-haavard.skinnemoen@atmel.com>
Cc: vibisreenivasan <vibi_sreenivasan@cms.com>,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:56826 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbZCXK0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 06:26:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: vibisreenivasan <vibi_sreenivasan@cms.com>

Removed unused variable dev

Signed-off-by: vibi sreenivasan <vibi_sreenivasan@cms.com>
Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
 drivers/net/macb.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f6c4936..180f9c9 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -513,7 +513,6 @@ static int macb_rx(struct macb *bp, int budget)
 static int macb_poll(struct napi_struct *napi, int budget)
 {
 	struct macb *bp = container_of(napi, struct macb, napi);
-	struct net_device *dev = bp->dev;
 	int work_done;
 	u32 status;
 
-- 
1.6.0.4

