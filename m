From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] net: Kill ether_table[] declaration.
Date: Thu, 26 May 2011 16:43:17 -0400 (EDT)
Message-ID: <20110526.164317.1149987126641398986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321Ab1EZUnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 16:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This got missed back in 2006 when Jes Sorensen deleted
net/ethernet/sysctl_net_ether.c

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/if_ether.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 0f1325d..0065ffd 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -132,10 +132,6 @@ static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
 
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 
-#ifdef CONFIG_SYSCTL
-extern struct ctl_table ether_table[];
-#endif
-
 int mac_pton(const char *s, u8 *mac);
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
-- 
1.7.4.4

