From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 3/3] net: define feature flags for FCoE offloads
Date: Mon, 06 Oct 2008 16:39:29 -0700
Message-ID: <20081006233928.4918.96135.stgit@zyfc9ini.jf.intel.com>
References: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61954 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbYJFXmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 19:42:04 -0400
In-Reply-To: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/netdevice.h |    3 +++
 include/linux/skbuff.h    |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index add9937..ba6ded1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -522,6 +522,8 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
+#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0x00ff0000
@@ -530,6 +532,7 @@ struct net_device
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_FCOE	(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
 
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 720b688..be60560 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -188,6 +188,8 @@ enum {
 	SKB_GSO_TCP_ECN = 1 << 3,
 
 	SKB_GSO_TCPV6 = 1 << 4,
+
+	SKB_GSO_FCOE = 1 << 5,
 };
 
 #if BITS_PER_LONG > 32

