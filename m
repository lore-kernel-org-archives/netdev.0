From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 07/12] headers, tipc: Add missing #include to
 <linux/tipc_config.h> for userland
Date: Mon, 08 Aug 2011 14:19:54 +0100
Message-ID: <1312809594.2591.1146.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50072 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab1HHNUA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:20:00 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/tipc_config.h> defines inline functions using ntohs() etc.
For userland these are defined in <arpa/inet.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/tipc_config.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 0db2395..9730b0e 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -41,6 +41,10 @@
 #include <linux/string.h>
 #include <asm/byteorder.h>
 
+#ifndef __KERNEL__
+#include <arpa/inet.h> /* for ntohs etc. */
+#endif
+
 /*
  * Configuration
  *
-- 
1.7.5.4



