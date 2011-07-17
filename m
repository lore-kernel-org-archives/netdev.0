From: David Lamparter <equinox@diac24.net>
Subject: [PATCH] net: add 802.1ad / 802.1ah / QinQ ethertypes
Date: Sun, 17 Jul 2011 20:32:12 +0200
Message-ID: <1310927532-3429374-1-git-send-email-equinox@diac24.net>
Cc: netdev@vger.kernel.org, David Lamparter <equinox@diac24.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:35714 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693Ab1GQSdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 14:33:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

define ETH_P_8021AD to 88a8 (assigned by IEEE) and add ETH_P_QINQ{1,2,3}
for the pre-standard 9{1,2,3}00 types. all of them use 802.1q frame
format, with 1 bit used differently in some cases.

also define ETH_P_8021AH to 88e7 (assigned by IEEE). this is Mac-in-Mac
and uses a different, 16-byte header.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
support for these coming up in a few hours, just polishing...

 include/linux/if_ether.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 0065ffd..a3d99ff 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -78,10 +78,15 @@
 					 */
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
+#define ETH_P_8021AD	0x88A8          /* 802.1ad Service VLAN		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
+#define ETH_P_QINQ1	0x9100		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
+#define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
+#define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*
-- 
1.7.5.3

