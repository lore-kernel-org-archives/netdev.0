From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 1/2] net: if_arp: add ARPHRD_RAWIP type
Date: Wed, 30 Oct 2013 11:11:10 +0200
Message-ID: <1383124271-15290-2-git-send-email-jukka.rissanen@linux.intel.com>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab3J3JLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 05:11:14 -0400
In-Reply-To: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used when there is no L2 header before IP header.
Example of this is Bluetooth 6LoWPAN network.

The RAWIP header type value is already used in some Android kernels
so same value is used here in order not to break userspace.

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 include/uapi/linux/if_arp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index d7fea34..06fc69f 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -59,6 +59,7 @@
 #define ARPHRD_LAPB	516		/* LAPB				*/
 #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
 #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
+#define ARPHRD_RAWIP	530	        /* Raw IP                       */
 
 #define ARPHRD_TUNNEL	768		/* IPIP tunnel			*/
 #define ARPHRD_TUNNEL6	769		/* IP6IP6 tunnel       		*/
-- 
1.7.11.7
