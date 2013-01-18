From: Amos Kong <kongjianjun@gmail.com>
Subject: [PATCH] net: fix wrong length of mac address
Date: Fri, 18 Jan 2013 10:15:21 +0800
Message-ID: <1358475321-3406-1-git-send-email-kongjianjun@gmail.com>
Cc: devel@linuxdriverproject.org, Amos Kong <kongjianjun@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869Ab3ARCPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 21:15:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace hardcode 14 with defined ETN_ALEN.

Signed-off-by: Amos Kong <kongjianjun@gmail.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f825a62..8264f0e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -349,7 +349,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	struct net_device_context *ndevctx = netdev_priv(ndev);
 	struct hv_device *hdev =  ndevctx->device_ctx;
 	struct sockaddr *addr = p;
-	char save_adr[14];
+	char save_adr[ETH_ALEN];
 	unsigned char save_aatype;
 	int err;
 
-- 
1.7.11.7
