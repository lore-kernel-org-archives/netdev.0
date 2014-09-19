From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 05/12] be2net: remove return statements for void functions
Date: Fri, 19 Sep 2014 15:46:55 +0530
Message-ID: <1411121822-25842-6-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbaISKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:31 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 --
 drivers/net/ethernet/emulex/benet/be_main.c    |    3 ---
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index ec66f64..32c61f3 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -975,8 +975,6 @@ static void be_set_msg_level(struct net_device *netdev, u32 level)
 						FW_LOG_LEVEL_DEFAULT :
 						FW_LOG_LEVEL_FATAL);
 	adapter->msg_enable = level;
-
-	return;
 }
 
 static u64 be_get_rss_hash_opts(struct be_adapter *adapter, u64 flow_type)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index beebab6..96be231 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3716,8 +3716,6 @@ static void be_netpoll(struct net_device *netdev)
 		be_eq_notify(eqo->adapter, eqo->q.id, false, true, 0);
 		napi_schedule(&eqo->napi);
 	}
-
-	return;
 }
 #endif
 
@@ -4395,7 +4393,6 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	return;
 err:
 	be_disable_vxlan_offloads(adapter);
-	return;
 }
 
 static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
-- 
1.7.1
