From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 01/12] headers, pppox: Add missing #include to
 <linux/if_pppox.h>
Date: Mon, 08 Aug 2011 14:16:55 +0100
Message-ID: <1312809415.2591.1140.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Michal Ostrowski <mostrows@earthlink.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55897 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752135Ab1HHNRD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:17:03 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/if_ppox.h> uses ETH_ALEN, defined in <linux/if_ether.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if_pppox.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 397921b..60e5558 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -20,8 +20,8 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
 
-#ifdef  __KERNEL__
 #include <linux/if_ether.h>
+#ifdef  __KERNEL__
 #include <linux/if.h>
 #include <linux/netdevice.h>
 #include <linux/ppp_channel.h>
-- 
1.7.5.4



