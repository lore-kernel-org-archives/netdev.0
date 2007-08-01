From: Jan Altenberg <jan.altenberg@linutronix.de>
Subject: [PATCH] remove get_perm_addr from ucc_geth_ethtool.c
Date: Wed, 01 Aug 2007 17:04:10 +0200
Message-ID: <1185980650.3854.63.camel@bender.lan>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:53198 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932372AbXHAPEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 11:04:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove get_perm_addr from ucc_geth_ethtool.c

This is needed because commit 313674afa8fdced2fe79f50f38e1c387b63d8790
inlines the generic function to the caller.

Signed-off-by: Jan Altenberg <jan.altenberg@linutronix.de>

---
 drivers/net/ucc_geth_ethtool.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6/drivers/net/ucc_geth_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/ucc_geth_ethtool.c
+++ linux-2.6/drivers/net/ucc_geth_ethtool.c
@@ -379,7 +379,6 @@ static const struct ethtool_ops uec_etht
 	.get_stats_count        = uec_get_stats_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
-	.get_perm_addr          = ethtool_op_get_perm_addr,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)


