From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH net-next] ethernet: fix min/max MTU typos
Date: Mon, 24 Oct 2016 14:42:26 +0200
Message-ID: <20161024144226.70480d4b@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarod Wilson <jarod@redhat.com>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes: d894be57ca92('ethernet: use net core MTU range checking in more drivers')
CC: Jarod Wilson <jarod@redhat.com>
CC: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/net/ethernet/broadcom/sb1250-mac.c | 2 +-
 drivers/net/ethernet/ibm/ibmveth.c         | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index cb312e4c89f4..435a2e4739d1 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2219,7 +2219,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 
 	dev->netdev_ops = &sbmac_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->max_mtu = 0;
+	dev->min_mtu = 0;
 	dev->max_mtu = ENET_PACKET_SIZE;
 
 	netif_napi_add(dev, &sc->napi, sbmac_poll, 16);
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 29c05d0d79a9..4a81c892fc31 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1549,7 +1549,7 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->min_mtu = IBMVETH_MIN_MTU;
-	netdev->min_mtu = ETH_MAX_MTU;
+	netdev->max_mtu = ETH_MAX_MTU;
 
 	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
-- 
Stefan Richter
-======----- =-=- ==---
http://arcgraph.de/sr/
