From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH RESEND 4/8] net: fs_enet: remove unnecessary dev_set_drvdata()
Date: Wed, 14 Aug 2013 11:39:41 +0800
Message-ID: <520AFBFD.6020005@huawei.com>
References: <5208E222.60300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>, <vbordug@ru.mvista.com>,
	<pantelis.antoniou@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E222.60300@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 8de53a1..7e3de10 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1122,7 +1122,6 @@ static int fs_enet_remove(struct platform_device *ofdev)

 	fep->ops->free_bd(ndev);
 	fep->ops->cleanup_data(ndev);
-	dev_set_drvdata(fep->dev, NULL);
 	of_node_put(fep->fpi->phy_node);
 	free_netdev(ndev);
 	return 0;
-- 
1.7.1
