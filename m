From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [net-next-2.6 PATCH 3/5] net: Add NETIF_F_FCOE_MTU to
	indicate	support for a different MTU for FCoE
Date: Wed, 22 Jul 2009 16:29:09 -0700
Message-ID: <20090722232909.26937.31565.stgit@localhost.localdomain>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
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

From: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Add NETIF_F_FCOE_MTU to indicate that the NIC can support a secondary MTU for
converged traffic of LAN and Fiber Channel over Ethernet (FCoE). The MTU for
FCoE is 2158 = 14 (FCoE header) + 24 (FC header) + 2112 (FC max payload) +
4 (FC CRC) + 4 (FCoE trailer).

Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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
