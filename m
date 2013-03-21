From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH] net: sh-eth: Use pr_err instead of printk
Date: Thu, 21 Mar 2013 17:46:55 +0900
Message-ID: <1363855615-30551-1-git-send-email-horms+renesas@verge.net.au>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39223 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab3CUIrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 04:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 56884c4..f632085 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -592,7 +592,7 @@ static int sh_eth_check_reset(struct net_device *ndev)
 		cnt--;
 	}
 	if (cnt < 0) {
-		printk(KERN_ERR "Device reset fail\n");
+		pr_err("Device reset fail\n");
 		ret = -ETIMEDOUT;
 	}
 	return ret;
@@ -2321,7 +2321,7 @@ static const u16 *sh_eth_get_register_offset(int register_type)
 		reg_offset = sh_eth_offset_fast_sh3_sh2;
 		break;
 	default:
-		printk(KERN_ERR "Unknown register type (%d)\n", register_type);
+		pr_err("Unknown register type (%d)\n", register_type);
 		break;
 	}
 
-- 
1.7.10.4
