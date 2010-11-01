From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-2.6 3/3] cxgb4vf: remove call to stop TX queues at load
	time.
Date: Mon, 01 Nov 2010 13:59:51 -0700
Message-ID: <20101101205951.27716.64800.stgit@speedy5.asicdesigners.com>
References: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Stopping TX queues at driver load time is not necessary.

Signed-off-by: Casey Leedom <leedom@chelsio.com>

---

 drivers/net/cxgb4vf/cxgb4vf_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 555ecc5..6de5e2e 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2600,7 +2600,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		pi->xact_addr_filt = -1;
 		pi->rx_offload = RX_CSO;
 		netif_carrier_off(netdev);
-		netif_tx_stop_all_queues(netdev);
 		netdev->irq = pdev->irq;
 
 		netdev->features = (NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
