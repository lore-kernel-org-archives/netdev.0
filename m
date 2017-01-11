From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] sfc: efx_get_phys_port_id() can be static
Date: Wed, 11 Jan 2017 16:16:12 +0000
Message-ID: <20170111161612.14384-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36472 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdAKQQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:16:20 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so15901299pgf.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 08:16:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/ethernet/sfc/efx.c:2337:5: warning:
 symbol 'efx_get_phys_port_id' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/sfc/efx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 543fa48..f2ec853 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2334,8 +2334,8 @@ static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 	return 0;
 }
 
-int efx_get_phys_port_id(struct net_device *net_dev,
-			 struct netdev_phys_item_id *ppid)
+static int efx_get_phys_port_id(struct net_device *net_dev,
+				struct netdev_phys_item_id *ppid)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
