From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 6/6] netdev: octeon_mgmt: Remove some gratuitous blank lines.
Date: Wed,  5 May 2010 16:03:13 -0700
Message-ID: <1273100593-11043-7-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1672 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758412Ab0EEXDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:50 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 1fdc7b3..3924703 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -380,7 +380,6 @@ done:
 	mix_ircnt.s.ircnt = 1;
 	cvmx_write_csr(CVMX_MIXX_IRCNT(port), mix_ircnt.u64);
 	return rc;
-
 }
 
 static int octeon_mgmt_receive_packets(struct octeon_mgmt *p, int budget)
@@ -390,7 +389,6 @@ static int octeon_mgmt_receive_packets(struct octeon_mgmt *p, int budget)
 	union cvmx_mixx_ircnt mix_ircnt;
 	int rc;
 
-
 	mix_ircnt.u64 = cvmx_read_csr(CVMX_MIXX_IRCNT(port));
 	while (work_done < budget && mix_ircnt.s.ircnt) {
 
@@ -516,7 +514,6 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 			octeon_mgmt_cam_state_add(&cam_state, ha->addr);
 	}
 
-
 	spin_lock_irqsave(&p->lock, flags);
 
 	/* Disable packet I/O. */
@@ -525,7 +522,6 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	agl_gmx_prtx.s.en = 0;
 	cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port), agl_gmx_prtx.u64);
 
-
 	adr_ctl.u64 = 0;
 	adr_ctl.s.cam_mode = cam_mode;
 	adr_ctl.s.mcst = multicast_mode;
@@ -928,7 +924,6 @@ static int octeon_mgmt_stop(struct net_device *netdev)
 
 	octeon_mgmt_reset_hw(p);
 
-
 	free_irq(p->irq, netdev);
 
 	/* dma_unmap is a nop on Octeon, so just free everything.  */
@@ -945,7 +940,6 @@ static int octeon_mgmt_stop(struct net_device *netdev)
 			 DMA_BIDIRECTIONAL);
 	kfree(p->tx_ring);
 
-
 	return 0;
 }
 
@@ -1112,7 +1106,6 @@ static int __init octeon_mgmt_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &octeon_mgmt_ops;
 	netdev->ethtool_ops = &octeon_mgmt_ethtool_ops;
 
-
 	/* The mgmt ports get the first N MACs.  */
 	for (i = 0; i < 6; i++)
 		netdev->dev_addr[i] = octeon_bootinfo->mac_addr_base[i];
-- 
1.6.6.1

