From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/10] drivers/net/qlge: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:28 -0800
Message-ID: <3a4c474a1f0fc81c0412abf9d99c0bd0365b9174.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlge/qlge_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c30e0fe..d9a7626 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3844,7 +3844,7 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 
 static void ql_display_dev_info(struct net_device *ndev)
 {
-	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
 
 	netif_info(qdev, probe, qdev->ndev,
 		   "Function #%d, Port %d, NIC Roll %d, NIC Rev = %d, "
@@ -4264,7 +4264,7 @@ static struct net_device_stats *qlge_get_stats(struct net_device
 
 static void qlge_set_multicast_list(struct net_device *ndev)
 {
-	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
 	struct netdev_hw_addr *ha;
 	int i, status;
 
@@ -4354,7 +4354,7 @@ exit:
 
 static int qlge_set_mac_address(struct net_device *ndev, void *p)
 {
-	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
 	struct sockaddr *addr = p;
 	int status;
 
@@ -4377,7 +4377,7 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 
 static void qlge_tx_timeout(struct net_device *ndev)
 {
-	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
 	ql_queue_asic_error(qdev);
 }
 
-- 
1.7.3.1.g432b3.dirty
