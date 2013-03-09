From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net] 6lowpan: Fix endianness issue in is_addr_link_local().
Date: Sun, 10 Mar 2013 04:11:57 +0900
Message-ID: <513B897D.2000207@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42582 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750737Ab3CITL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 14:11:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ieee802154/6lowpan.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 8c2251f..bba5f83 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -84,7 +84,7 @@
 	(memcmp(addr1, addr2, length >> 3) == 0)
 
 /* local link, i.e. FE80::/10 */
-#define is_addr_link_local(a) (((a)->s6_addr16[0]) == 0x80FE)
+#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80))
 
 /*
  * check whether we can compress the IID to 16 bits,
-- 
1.7.9.5
