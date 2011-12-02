From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V0 13/21] mlx4_ib: disable SRIOV mode for IB ports
 (not yet supported)
Date: Fri, 2 Dec 2011 12:18:14 +0200
Message-ID: <4ED8A5E6.2050908@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 35b876e..ee9c41b 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1074,6 +1074,11 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 
 	printk_once(KERN_INFO "%s", mlx4_ib_version);
 
+	if (mlx4_is_mfunc(dev)) {
+		printk(KERN_WARNING "IB not yet supported in SRIOV\n");
+		return NULL;
+	}
+
 	mlx4_foreach_ib_transport_port(i, dev)
 		num_ports++;
 
-- 
1.7.7





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
