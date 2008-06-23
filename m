From: Julius Volz <juliusv@google.com>
Subject: [PATCH] Netlink: Fix some doc comments in net/netlink/attr.c
Date: Mon, 23 Jun 2008 21:19:11 +0200
Message-ID: <1214248751-6498-1-git-send-email-juliusv@google.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	Julius Volz <juliusv@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:48825 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333AbYFWTT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 15:19:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some doc comments to match function and attribute names in
net/netlink/attr.c.

Signed-off-by: Julius Volz <juliusv@google.com>
---
 net/netlink/attr.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index 47bbf45..2d106cf 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -132,6 +132,7 @@ errout:
  * @maxtype: maximum attribute type to be expected
  * @head: head of attribute stream
  * @len: length of attribute stream
+ * @policy: validation policy
  *
  * Parses a stream of attributes and stores a pointer to each attribute in
  * the tb array accessable via the attribute type. Attributes with a type
@@ -194,7 +195,7 @@ struct nlattr *nla_find(struct nlattr *head, int len, int attrtype)
 /**
  * nla_strlcpy - Copy string attribute payload into a sized buffer
  * @dst: where to copy the string to
- * @src: attribute to copy the string from
+ * @nla: attribute to copy the string from
  * @dstsize: size of destination buffer
  *
  * Copies at most dstsize - 1 bytes into the destination buffer.
@@ -340,9 +341,9 @@ struct nlattr *nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 }
 
 /**
- * nla_reserve - reserve room for attribute without header
+ * nla_reserve_nohdr - reserve room for attribute without header
  * @skb: socket buffer to reserve room on
- * @len: length of attribute payload
+ * @attrlen: length of attribute payload
  *
  * Reserves room for attribute payload without a header.
  *
-- 
1.5.3.6

