From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 22/51] netlink: Add nla_put_net{16,32,64}() helpers.
Date: Sun,  1 Apr 2012 22:58:12 -0400
Message-ID: <1333335521-1348-23-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2DBC7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:39 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netlink.h |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index fce17f6..73656aa 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -783,6 +783,17 @@ static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
 }
 
 /**
+ * nla_put_net16 - Add 16-bit network byte order netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
+{
+	return nla_put_be16(skb, attrtype | NLA_F_NET_BYTEORDER, value);
+}
+
+/**
  * nla_put_u32 - Add a u32 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -805,6 +816,17 @@ static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
 }
 
 /**
+ * nla_put_net32 - Add 32-bit network byte order netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
+{
+	return nla_put_be32(skb, attrtype | NLA_F_NET_BYTEORDER, value);
+}
+
+/**
  * nla_put_u64 - Add a u64 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -827,6 +849,17 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value)
 }
 
 /**
+ * nla_put_net64 - Add 64-bit network byte order netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
+{
+	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value);
+}
+
+/**
  * nla_put_string - Add a string netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
-- 
1.7.7.6
