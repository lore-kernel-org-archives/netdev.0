From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: use matching format identifiers
Date: Fri, 19 Aug 2016 23:19:45 -0700
Message-ID: <1471673991-117115-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Heinrich Schuchardt <xypron.glpk@gmx.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:50330 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752485AbcHTGT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:56 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>

i is defined as int but output as %u several times.
Adjust the format identifiers.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5bd3848..1835186 100644
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
2.7.4
