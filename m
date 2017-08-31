From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: qualcomm: rmnet: remove unused variable priv
Date: Thu, 31 Aug 2017 15:07:27 +0100
Message-ID: <20170831140727.28170-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49505 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdHaOHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 10:07:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

priv is being assigned but is never used, so remove it.

Cleans up clang build warning:
"warning: Value stored to 'priv' is never read"

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index c8b573d28dcf..bf7455fdafcc 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -73,9 +73,6 @@ static const struct net_device_ops rmnet_vnd_ops = {
  */
 void rmnet_vnd_setup(struct net_device *rmnet_dev)
 {
-	struct rmnet_priv *priv;
-
-	priv = netdev_priv(rmnet_dev);
 	netdev_dbg(rmnet_dev, "Setting up device %s\n", rmnet_dev->name);
 
 	rmnet_dev->netdev_ops = &rmnet_vnd_ops;
-- 
2.14.1
