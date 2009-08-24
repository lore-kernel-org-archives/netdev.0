From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/2] irda/au1k_ir: fix broken netdev_ops conversion
Date: Mon, 24 Aug 2009 18:54:27 +0400
Message-ID: <1251125667-6509-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:52490 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbZHXQZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 12:25:12 -0400
Received: by ewy3 with SMTP id 3so2547410ewy.18
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 09:25:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is based on commit d2f3ad4 (pxaficp-ir: remove incorrect
net_device_ops). Do the same for au1k_ir.
Untested.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/irda/au1k_ir.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index c4361d4..ee1cff5 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -23,7 +23,6 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/interrupt.h>
@@ -205,9 +204,6 @@ static const struct net_device_ops au1k_irda_netdev_ops = {
 	.ndo_start_xmit		= au1k_irda_hard_xmit,
 	.ndo_tx_timeout		= au1k_tx_timeout,
 	.ndo_do_ioctl		= au1k_irda_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
 };
 
 static int au1k_irda_net_init(struct net_device *dev)
-- 
1.6.4

