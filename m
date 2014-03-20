From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] igbvf: Convert uses of __constant_<foo> to <foo>
Date: Thu, 20 Mar 2014 01:32:54 -0700
Message-ID: <1395304385-6874-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbaCTIdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:49 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index e2c6d80..b7ab03a 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2014,12 +2014,12 @@ static inline bool igbvf_tx_csum(struct igbvf_adapter *adapter,
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
+			case htons(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
 				break;
-			case __constant_htons(ETH_P_IPV6):
+			case htons(ETH_P_IPV6):
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
 				break;
-- 
1.8.3.1
