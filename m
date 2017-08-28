From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/4] ether: add NSH ethertype
Date: Mon, 28 Aug 2017 21:43:21 +0200
Message-ID: <aba1f3a4c0724041d11ea571176db39ac30e55bd.1503948295.git.jbenc@redhat.com>
References: <cover.1503948295.git.jbenc@redhat.com>
Cc: Yi Yang <yi.y.yang@intel.com>, Eric Garver <e@erig.me>,
        Jan Scheurich <jan.scheurich@ericsson.com>,
        Ben Pfaff <blp@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdH1Tnk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 15:43:40 -0400
In-Reply-To: <cover.1503948295.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NSH draft says:

   An IEEE EtherType, 0x894F, has been allocated for NSH.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index efeb1190c2ca..d7b47e97904f 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -99,6 +99,7 @@
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
 #define ETH_P_80221	0x8917		/* IEEE 802.21 Media Independent Handover Protocol */
 #define ETH_P_HSR	0x892F		/* IEC 62439-3 HSRv1	*/
+#define ETH_P_NSH	0x894F		/* Network Service Header */
 #define ETH_P_LOOPBACK	0x9000		/* Ethernet loopback packet, per IEEE 802.3 */
 #define ETH_P_QINQ1	0x9100		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
-- 
1.8.3.1
