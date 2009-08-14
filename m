From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 03/12] net: Add NETIF_F_FCOE_MTU to indicate support
	for a different MTU for FCoE
Date: Fri, 14 Aug 2009 15:41:57 -0700
Message-ID: <20090814224156.1640.59034.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

Add NETIF_F_FCOE_MTU to indicate that the NIC can support a secondary MTU for
converged traffic of LAN and Fiber Channel over Ethernet (FCoE). The MTU for
FCoE is 2158 = 14 (FCoE header) + 24 (FC header) + 2112 (FC max payload) +
4 (FC CRC) + 4 (FCoE trailer).

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9f25ab2..9192cdf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -701,6 +701,7 @@ struct net_device
 /* the GSO_MASK reserves bits 16 through 23 */
 #define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
 #define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
+#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16

