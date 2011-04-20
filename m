From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V3 7/8] Enable ixgbe to support zerocopy
Date: Wed, 20 Apr 2011 13:15:15 -0700
Message-ID: <1303330515.19336.59.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303328216.19336.18.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6f8adc7..68f1e93 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7395,6 +7395,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #endif /* IXGBE_FCOE */
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_ZEROCOPY;
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
