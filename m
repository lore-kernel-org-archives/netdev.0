From: Robert Love <robert.w.love@intel.com>
Subject: [PATCH] net: Add the FCoE Initialization Protocol ethertype
Date: Fri, 01 May 2009 11:55:32 -0700
Message-ID: <20090501185532.14602.21059.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61520 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbZEASzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 14:55:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FIP is the FCoE Initialization Protocol and this patch
adds the protocol ethertype to the kernel's list of
ethertypes.

Signed-off-by: Joe Eykholt <jeykholt@cisco.com>
Signed-off-by: Robert Love <robert.w.love@intel.com>
---

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index cfe4fe1..60e8934 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -79,6 +79,7 @@
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
+#define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*

