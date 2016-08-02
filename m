From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1 v2] net: i10e: use matching format indentifiers
Date: Tue,  2 Aug 2016 20:15:18 +0200
Message-ID: <1470161718-8824-1-git-send-email-xypron.glpk@gmx.de>
References: <20160731.204759.1283451349474511870.davem@davemloft.net>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:52915 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757401AbcHBSgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 14:36:38 -0400
In-Reply-To: <20160731.204759.1283451349474511870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i is defined as int but output as %u several times.
Adjust the format identifiers.

v2:
	Keep definition of i as int.
	David indicated that this is the preferable way to define
	loop variables.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c912e04..94ac712 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1560,13 +1560,13 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		}
 #endif
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			snprintf(p, ETH_GSTRING_LEN, "tx-%u.tx_packets", i);
+			snprintf(p, ETH_GSTRING_LEN, "tx-%d.tx_packets", i);
 			p += ETH_GSTRING_LEN;
-			snprintf(p, ETH_GSTRING_LEN, "tx-%u.tx_bytes", i);
+			snprintf(p, ETH_GSTRING_LEN, "tx-%d.tx_bytes", i);
 			p += ETH_GSTRING_LEN;
-			snprintf(p, ETH_GSTRING_LEN, "rx-%u.rx_packets", i);
+			snprintf(p, ETH_GSTRING_LEN, "rx-%d.rx_packets", i);
 			p += ETH_GSTRING_LEN;
-			snprintf(p, ETH_GSTRING_LEN, "rx-%u.rx_bytes", i);
+			snprintf(p, ETH_GSTRING_LEN, "rx-%d.rx_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
 		if (vsi != pf->vsi[pf->lan_vsi] || pf->hw.partition_id != 1)
@@ -1581,16 +1581,16 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 			}
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 				snprintf(p, ETH_GSTRING_LEN,
-					 "veb.tc_%u_tx_packets", i);
+					 "veb.tc_%d_tx_packets", i);
 				p += ETH_GSTRING_LEN;
 				snprintf(p, ETH_GSTRING_LEN,
-					 "veb.tc_%u_tx_bytes", i);
+					 "veb.tc_%d_tx_bytes", i);
 				p += ETH_GSTRING_LEN;
 				snprintf(p, ETH_GSTRING_LEN,
-					 "veb.tc_%u_rx_packets", i);
+					 "veb.tc_%d_rx_packets", i);
 				p += ETH_GSTRING_LEN;
 				snprintf(p, ETH_GSTRING_LEN,
-					 "veb.tc_%u_rx_bytes", i);
+					 "veb.tc_%d_rx_bytes", i);
 				p += ETH_GSTRING_LEN;
 			}
 		}
@@ -1601,23 +1601,23 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		}
 		for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
 			snprintf(p, ETH_GSTRING_LEN,
-				 "port.tx_priority_%u_xon", i);
+				 "port.tx_priority_%d_xon", i);
 			p += ETH_GSTRING_LEN;
 			snprintf(p, ETH_GSTRING_LEN,
-				 "port.tx_priority_%u_xoff", i);
+				 "port.tx_priority_%d_xoff", i);
 			p += ETH_GSTRING_LEN;
 		}
 		for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
 			snprintf(p, ETH_GSTRING_LEN,
-				 "port.rx_priority_%u_xon", i);
+				 "port.rx_priority_%d_xon", i);
 			p += ETH_GSTRING_LEN;
 			snprintf(p, ETH_GSTRING_LEN,
-				 "port.rx_priority_%u_xoff", i);
+				 "port.rx_priority_%d_xoff", i);
 			p += ETH_GSTRING_LEN;
 		}
 		for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
 			snprintf(p, ETH_GSTRING_LEN,
-				 "port.rx_priority_%u_xon_2_xoff", i);
+				 "port.rx_priority_%d_xon_2_xoff", i);
 			p += ETH_GSTRING_LEN;
 		}
 		/* BUG_ON(p - data != I40E_STATS_LEN * ETH_GSTRING_LEN); */
-- 
2.1.4
