From: Neil Jerram <Neil.Jerram@metaswitch.com>
Subject: [PATCH net-next] net: order MPLS ethertypes numerically
Date: Tue, 25 Feb 2014 11:17:25 +0000
Message-ID: <1393327045-7170-1-git-send-email-Neil.Jerram@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <horms@verge.net.au>,
	Neil Jerram <Neil.Jerram@metaswitch.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enficsets1.metaswitch.com ([192.91.191.38]:20377 "EHLO
	ENFICSETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbaBYLTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 06:19:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ethertypes other than ETH_P_MPLS_UC, ETH_P_MPLS_MC and
ETH_P_ATMMPOA were already ordered numerically.  This commit moves
those three ETH_P_... values into correct numerical order too.

Signed-off-by: Neil Jerram <Neil.Jerram@metaswitch.com>
---
 include/uapi/linux/if_ether.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 2ce0f6a..ba8b15f 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -68,11 +68,11 @@
 #define ETH_P_SLOW	0x8809		/* Slow Protocol. See 802.3ad 43B */
 #define ETH_P_WCCP	0x883E		/* Web-cache coordination protocol
 					 * defined in draft-wilson-wrec-wccp-v2-00.txt */
-#define ETH_P_PPP_DISC	0x8863		/* PPPoE discovery messages     */
-#define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
 #define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic		*/
 #define ETH_P_MPLS_MC	0x8848		/* MPLS Multicast traffic	*/
 #define ETH_P_ATMMPOA	0x884c		/* MultiProtocol Over ATM	*/
+#define ETH_P_PPP_DISC	0x8863		/* PPPoE discovery messages     */
+#define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
 #define ETH_P_LINK_CTL	0x886c		/* HPNA, wlan link local tunnel */
 #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
 					 * over Ethernet
-- 
1.7.10.4
