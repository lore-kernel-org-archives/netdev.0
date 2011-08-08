From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 08/12] headers, netfilter: Add missing #include <limits.h>
 for userland
Date: Mon, 08 Aug 2011 14:20:13 +0100
Message-ID: <1312809613.2591.1147.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50084 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab1HHNUT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:20:19 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various headers use INT_MIN and INT_MAX, which are defined for
userland in <limits.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netfilter_decnet.h |    3 +++
 include/linux/netfilter_ipv4.h   |    3 +++
 include/linux/netfilter_ipv6.h   |    3 +++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter_decnet.h b/include/linux/netfilter_decnet.h
index 6f42536..0b09732 100644
--- a/include/linux/netfilter_decnet.h
+++ b/include/linux/netfilter_decnet.h
@@ -11,6 +11,9 @@
 
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_DN_SRC		0x0001
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index 29c7727..fa0946c 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -9,6 +9,9 @@
 
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_IP_SRC		0x0001
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 1f7e300..57c0251 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -12,6 +12,9 @@
 
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_IP6_SRC              0x0001
-- 
1.7.5.4



