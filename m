From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 5/8] netdev: octeon_mgmt: Set the parent device.
Date: Tue, 21 Aug 2012 11:45:09 -0700
Message-ID: <1345574712-21444-6-git-send-email-ddaney.cavm@gmail.com>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

This establishes useful links in sysfs.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index cf06cf2..3bae01f 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1446,6 +1446,8 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 	if (netdev == NULL)
 		return -ENOMEM;
 
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
 	dev_set_drvdata(&pdev->dev, netdev);
 	p = netdev_priv(netdev);
 	netif_napi_add(netdev, &p->napi, octeon_mgmt_napi_poll,
-- 
1.7.11.4
