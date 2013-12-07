From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH net-next 1/2] net: if_arp: add ARPHRD_6LOWPAN type
Date: Sat,  7 Dec 2013 20:08:56 +0200
Message-ID: <1386439737-14894-2-git-send-email-jukka.rissanen@linux.intel.com>
References: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55153 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755236Ab3LGSJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 13:09:03 -0500
In-Reply-To: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used for IPv6 over LoWPAN networks. Example of this is
Bluetooth 6LoWPAN network.

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 include/uapi/linux/if_arp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index d7fea34..4d024d7 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -94,6 +94,7 @@
 #define ARPHRD_CAIF	822		/* CAIF media type		*/
 #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 #define ARPHRD_NETLINK	824		/* Netlink header		*/
+#define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
-- 
1.8.3.1
