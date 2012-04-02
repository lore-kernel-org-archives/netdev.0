From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 05/51] netlink: Add nla_put_be{16,32,64}() helpers.
Date: Sun,  1 Apr 2012 22:57:55 -0400
Message-ID: <1333335521-1348-6-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab2DBC7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:34 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netlink.h |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index f394fe5..fce17f6 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -772,6 +772,17 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
 }
 
 /**
+ * nla_put_be16 - Add a __be16 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
+{
+	return nla_put(skb, attrtype, sizeof(__be16), &value);
+}
+
+/**
  * nla_put_u32 - Add a u32 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -783,7 +794,18 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
 }
 
 /**
- * nla_put_64 - Add a u64 netlink attribute to a socket buffer
+ * nla_put_be32 - Add a __be32 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
+{
+	return nla_put(skb, attrtype, sizeof(__be32), &value);
+}
+
+/**
+ * nla_put_u64 - Add a u64 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
@@ -794,6 +816,17 @@ static inline int nla_put_u64(struct sk_buff *skb, int attrtype, u64 value)
 }
 
 /**
+ * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value)
+{
+	return nla_put(skb, attrtype, sizeof(__be64), &value);
+}
+
+/**
  * nla_put_string - Add a string netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
-- 
1.7.7.6
