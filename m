From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: updates vlan feature
	flags to enable	FCoE offloads on vlan interface
Date: Wed, 22 Jul 2009 16:28:43 -0700
Message-ID: <20090722232842.26937.3550.stgit@localhost.localdomain>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20090722232759.26937.78765.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Updates netdev->vlan_features for NETIF_F_FCOE_CRC and NETIF_F_FSO, so that
FCoE CRC and GSO offloads will get used for FCoE over ixgbe based vlan
interface.

Signed-off-by: Vasu Dev <vasu.dev-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 79f60e8..d89c695 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5588,6 +5588,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			if (!(device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)) {
 				netdev->features |= NETIF_F_FCOE_CRC;
 				netdev->features |= NETIF_F_FSO;
+				netdev->vlan_features |= NETIF_F_FCOE_CRC;
+				netdev->vlan_features |= NETIF_F_FSO;
 				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
 			} else {
 				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
