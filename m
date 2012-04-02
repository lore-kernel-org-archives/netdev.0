From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 28/51] netlink: Add nla_put_le{16,32,64}() helpers.
Date: Sun,  1 Apr 2012 22:58:18 -0400
Message-ID: <1333335521-1348-29-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab2DBC7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:55 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netlink.h |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 73656aa..efbd2c1 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -794,6 +794,17 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
 }
 
 /**
+ * nla_put_le16 - Add a __le16 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
+{
+	return nla_put(skb, attrtype, sizeof(__le16), &value);
+}
+
+/**
  * nla_put_u32 - Add a u32 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -827,6 +838,17 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
 }
 
 /**
+ * nla_put_le32 - Add a __le32 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
+{
+	return nla_put(skb, attrtype, sizeof(__le32), &value);
+}
+
+/**
  * nla_put_u64 - Add a u64 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -860,6 +882,17 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
 }
 
 /**
+ * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value)
+{
+	return nla_put(skb, attrtype, sizeof(__le64), &value);
+}
+
+/**
  * nla_put_string - Add a string netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
-- 
1.7.7.6
