From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2 2/2] net: sh-eth: Use pr_err instead of printk
Date: Tue, 16 Oct 2012 12:17:41 +0900
Message-ID: <1350357461-6017-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1350357461-6017-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:44273 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab2JPDR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 23:17:59 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so5542633pbb.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 20:17:59 -0700 (PDT)
In-Reply-To: <1350357461-6017-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 25f85d1..670a897 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -598,7 +598,7 @@ static int sh_eth_check_reset(struct net_device *ndev)
 		cnt--;
 	}
 	if (cnt < 0) {
-		printk(KERN_ERR "Device reset fail\n");
+		pr_err("Device reset fail\n");
 		ret = -ETIMEDOUT;
 	}
 	return ret;
@@ -2329,7 +2329,7 @@ static const u16 *sh_eth_get_register_offset(int register_type)
 		reg_offset = sh_eth_offset_fast_sh3_sh2;
 		break;
 	default:
-		printk(KERN_ERR "Unknown register type (%d)\n", register_type);
+		pr_err("Unknown register type (%d)\n", register_type);
 		break;
 	}
 
-- 
1.7.10.4
