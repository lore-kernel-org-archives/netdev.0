From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] netlink: fix description of portid
Date: Thu, 16 Oct 2014 15:47:51 +0200
Message-ID: <1413467271-6385-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34558 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbaJPNsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 09:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid confusion between pid and portid.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 6c1076275aaa..7b903e1bdbbb 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -431,7 +431,7 @@ static inline int nlmsg_report(const struct nlmsghdr *nlh)
 /**
  * nlmsg_put - Add a new netlink message to an skb
  * @skb: socket buffer to store message in
- * @portid: netlink process id
+ * @portid: netlink PORTID of requesting application
  * @seq: sequence number of message
  * @type: message type
  * @payload: length of message payload
-- 
2.1.0
