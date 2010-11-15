From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/10] drivers/net/qla3xxx.c: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:27 -0800
Message-ID: <de6d97d7116c0889bf2b01e45e99a2b8d1b13410.1289855436.git.joe@perches.com>
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
 drivers/net/qla3xxx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 7496ed2..1a3584e 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2467,7 +2467,7 @@ map_error:
 static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 			       struct net_device *ndev)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
+	struct ql3_adapter *qdev = netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
 	struct ql_tx_buf_cb *tx_cb;
@@ -3390,7 +3390,7 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
 
 static void ql_display_dev_info(struct net_device *ndev)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
+	struct ql3_adapter *qdev = netdev_priv(ndev);
 	struct pci_dev *pdev = qdev->pdev;
 
 	netdev_info(ndev,
@@ -3573,7 +3573,7 @@ static int ql3xxx_open(struct net_device *ndev)
 
 static int ql3xxx_set_mac_address(struct net_device *ndev, void *p)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
+	struct ql3_adapter *qdev = netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
 	struct sockaddr *addr = p;
@@ -3608,7 +3608,7 @@ static int ql3xxx_set_mac_address(struct net_device *ndev, void *p)
 
 static void ql3xxx_tx_timeout(struct net_device *ndev)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
+	struct ql3_adapter *qdev = netdev_priv(ndev);
 
 	netdev_err(ndev, "Resetting...\n");
 	/*
-- 
1.7.3.1.g432b3.dirty
