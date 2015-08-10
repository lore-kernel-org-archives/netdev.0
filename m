From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH net-next] mellanox: mlxsw: Use '%zx' to print size_t format
Date: Mon, 10 Aug 2015 09:54:28 -0300
Message-ID: <1439211268-8785-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@mellanox.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:55872
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751583AbbHJMyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 08:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use '%zx' to print size_t format in order to fix the following build warning:

drivers/net/ethernet/mellanox/mlxsw/item.h:65:3: warning: format '%lx' expects argument of type 'long unsigned int', but argument 6 has type 'size_t' [-Wformat=]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index 4d0ac88..ffd55d0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -62,7 +62,7 @@ __mlxsw_item_offset(struct mlxsw_item *item, unsigned short index,
 	if (item->offset % typesize != 0 ||
 	    item->step % typesize != 0 ||
 	    item->in_step_offset % typesize != 0) {
-		pr_err("mlxsw: item bug (name=%s,offset=%x,step=%x,in_step_offset=%x,typesize=%lx)\n",
+		pr_err("mlxsw: item bug (name=%s,offset=%x,step=%x,in_step_offset=%x,typesize=%zx)\n",
 		       item->name, item->offset, item->step,
 		       item->in_step_offset, typesize);
 		BUG();
-- 
1.9.1
