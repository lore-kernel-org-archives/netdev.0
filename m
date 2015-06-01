From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net] net/mlx4: fix typo in mlx4_set_vf_mac
Date: Mon,  1 Jun 2015 09:41:44 -0500
Message-ID: <1433169704-32307-3-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, jackm@mellanox.com,
	brking@linux.vnet.ibm.com, clsoto@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:45173 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbbFAOqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:46:40 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Mon, 1 Jun 2015 11:46:38 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 45E703520054
	for <netdev@vger.kernel.org>; Mon,  1 Jun 2015 10:45:32 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t51EjKRv7471434
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 11:45:20 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t51EkZ4v000579
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 10:46:35 -0400
In-Reply-To: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix typo in mlx4_set_vf_mac

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2687,7 +2687,7 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev
 	port = mlx4_slaves_closest_port(dev, slave, port);
 	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
 	s_info->mac = mac;
-	mlx4_info(dev, "default mac on vf %d port %d to %llX will take afect only after vf restart\n",
+	mlx4_info(dev, "default mac on vf %d port %d to %llX will take effect only after vf restart\n",
 		  vf, port, s_info->mac);
 	return 0;
 }
