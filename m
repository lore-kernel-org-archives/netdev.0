From: Wei Yongjun <weiyongjun1@huawei.com>
Subject: [PATCH net-next] net: aquantia: Make local functions static
Date: Sat, 28 Oct 2017 05:03:38 +0000
Message-ID: <1509167018-92434-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        David VomLehn <vomlehn@texas.net>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:9531 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ1FAI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:00:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sparse warnings:

drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c:224:5: warning:
 symbol 'aq_ethtool_get_coalesce' was not declared. Should it be static?
drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c:245:5: warning:
 symbol 'aq_ethtool_set_coalesce' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
index d5e99b4..70efb74 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
@@ -221,8 +221,8 @@ static int aq_ethtool_get_rxnfc(struct net_device *ndev,
 	return err;
 }
 
-int aq_ethtool_get_coalesce(struct net_device *ndev,
-			    struct ethtool_coalesce *coal)
+static int aq_ethtool_get_coalesce(struct net_device *ndev,
+				   struct ethtool_coalesce *coal)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
@@ -242,8 +242,8 @@ int aq_ethtool_get_coalesce(struct net_device *ndev,
 	return 0;
 }
 
-int aq_ethtool_set_coalesce(struct net_device *ndev,
-			    struct ethtool_coalesce *coal)
+static int aq_ethtool_set_coalesce(struct net_device *ndev,
+				   struct ethtool_coalesce *coal)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
