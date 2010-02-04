From: leitao@linux.vnet.ibm.com
Subject: [PATCH 2/2] qlge: Code clean up
Date: Thu,  4 Feb 2010 14:11:19 -0600
Message-ID: <5283aff9bf39e3e4282575f27a51b711f7e69010.1265314112.git.root@sanx1002.austin.ibm.com>
References: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:60068 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab0BDUNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:13:01 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp03.br.ibm.com (8.14.3/8.13.1) with ESMTP id o14K9a5Y003327
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:09:36 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o14KFUTL2306104
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:15:32 -0200
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o14KCunM030940
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:12:56 -0200
In-Reply-To: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
In-Reply-To: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
References: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just reordering this assignment that doesn't depend on any
condition.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c583fb5..0d6e6f8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4129,12 +4129,12 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 	queue_delayed_work(qdev->workqueue,
 			&qdev->mpi_port_cfg_work, 3*HZ);
 
+	ndev->mtu = new_mtu;
+
 	if (!netif_running(qdev->ndev)) {
-		ndev->mtu = new_mtu;
 		return 0;
 	}
 
-	ndev->mtu = new_mtu;
 	status = ql_change_rx_buffers(qdev);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR,
-- 
1.6.0.2

