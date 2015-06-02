From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next 3/3] net/mlx4_core: fix typo in mlx4_set_vf_mac
Date: Tue,  2 Jun 2015 16:07:25 -0500
Message-ID: <1433279245-5577-3-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, Carol Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:40397 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbFBVLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:11:55 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Tue, 2 Jun 2015 18:11:51 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 67A1D1DC006C
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:10:49 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t52LC9rp4907078
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:12:09 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t52LBmPP006804
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:11:49 -0300
In-Reply-To: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>

fix typo in mlx4_set_vf_mac

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 91d8344..68ae765 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2917,7 +2917,7 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 	port = mlx4_slaves_closest_port(dev, slave, port);
 	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
 	s_info->mac = mac;
-	mlx4_info(dev, "default mac on vf %d port %d to %llX will take afect only after vf restart\n",
+	mlx4_info(dev, "default mac on vf %d port %d to %llX will take effect only after vf restart\n",
 		  vf, port, s_info->mac);
 	return 0;
 }
-- 
1.8.3.1
