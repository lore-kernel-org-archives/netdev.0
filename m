From: varkabhadram@gmail.com
Subject: [PATCH net 5/7] net: cpmac: fix missing a blank line after declarations
Date: Thu, 10 Jul 2014 10:17:58 +0530
Message-ID: <1404967680-13206-6-git-send-email-varkabhadram@gmail.com>
References: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53928 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaGJEth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 00:49:37 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so10154847pdb.39
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 21:49:37 -0700 (PDT)
In-Reply-To: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch insert a blank line after declaration

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 1520c19..3d3ead4 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -224,6 +224,7 @@ static void cpmac_dump_regs(struct net_device *dev)
 {
 	int i;
 	struct cpmac_priv *priv = netdev_priv(dev);
+
 	for (i = 0; i < CPMAC_REG_END; i += 4) {
 		if (i % 16 == 0) {
 			if (i)
@@ -238,6 +239,7 @@ static void cpmac_dump_regs(struct net_device *dev)
 static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *desc)
 {
 	int i;
+
 	netdev_dbg(dev, "desc[%p]:", desc);
 	for (i = 0; i < sizeof(*desc) / 4; i++)
 		pr_debug(" %08x", ((u32 *)desc)[i]);
@@ -248,6 +250,7 @@ static void cpmac_dump_all_desc(struct net_device *dev)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 	struct cpmac_desc *dump = priv->rx_head;
+
 	do {
 		cpmac_dump_desc(dev, dump);
 		dump = dump->next;
@@ -257,6 +260,7 @@ static void cpmac_dump_all_desc(struct net_device *dev)
 static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	int i;
+
 	netdev_dbg(dev, "skb 0x%p, len=%d\n", skb, skb->len);
 	for (i = 0; i < skb->len; i++) {
 		if (i % 16 == 0) {
@@ -681,6 +685,7 @@ static void cpmac_clear_rx(struct net_device *dev)
 	struct cpmac_priv *priv = netdev_priv(dev);
 	struct cpmac_desc *desc;
 	int i;
+
 	if (unlikely(!priv->rx_head))
 		return;
 	desc = priv->rx_head;
@@ -703,6 +708,7 @@ static void cpmac_clear_tx(struct net_device *dev)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 	int i;
+
 	if (unlikely(!priv->desc_ring))
 		return;
 	for (i = 0; i < CPMAC_QUEUES; i++) {
@@ -821,6 +827,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
 static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
+
 	if (!(netif_running(dev)))
 		return -EINVAL;
 	if (!priv->phy)
@@ -1181,6 +1188,7 @@ fail:
 static int cpmac_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
+
 	unregister_netdev(dev);
 	free_netdev(dev);
 	return 0;
-- 
1.7.9.5
