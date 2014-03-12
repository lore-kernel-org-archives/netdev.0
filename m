From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 6/9] ixgbevf: Convert uses of
	__constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:22:35 -0700
Message-ID: <6477c916f14711f9f0cd02610a8b8a3c1804a83e.1394644825.git.joe@perches.com>
References: <cover.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1394644825.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6ac5da2..be56a9e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2851,12 +2851,12 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4_hdr = 0;
 		switch (skb->protocol) {
-		case __constant_htons(ETH_P_IP):
+		case htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
 			l4_hdr = ip_hdr(skb)->protocol;
 			break;
-		case __constant_htons(ETH_P_IPV6):
+		case htons(ETH_P_IPV6):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			l4_hdr = ipv6_hdr(skb)->nexthdr;
 			break;
-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
