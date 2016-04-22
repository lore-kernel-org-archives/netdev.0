From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/9] libnl: fix help of _64bit functions
Date: Fri, 22 Apr 2016 17:31:16 +0200
Message-ID: <1461339084-3849-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53596 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbcDVPcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:05 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo and describe 'padattr'.

Fixes: 089bf1a6a924 ("libnl: add more helpers to align attributes on 64-bit")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 lib/nlattr.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index 2b82f1e2ebc2..fce1e9afc6d9 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -359,10 +359,11 @@ EXPORT_SYMBOL(__nla_reserve);
  * @skb: socket buffer to reserve room on
  * @attrtype: attribute type
  * @attrlen: length of attribute payload
+ * @padattr: attribute type for the padding
  *
  * Adds a netlink attribute header to a socket buffer and reserves
  * room for the payload but does not copy it. It also ensure that this
- * attribute will be 64-bit aign.
+ * attribute will have a 64-bit aligned nla_data() area.
  *
  * The caller is responsible to ensure that the skb provides enough
  * tailroom for the attribute header and payload.
@@ -424,10 +425,11 @@ EXPORT_SYMBOL(nla_reserve);
  * @skb: socket buffer to reserve room on
  * @attrtype: attribute type
  * @attrlen: length of attribute payload
+ * @padattr: attribute type for the padding
  *
  * Adds a netlink attribute header to a socket buffer and reserves
  * room for the payload but does not copy it. It also ensure that this
- * attribute will be 64-bit aign.
+ * attribute will have a 64-bit aligned nla_data() area.
  *
  * Returns NULL if the tailroom of the skb is insufficient to store
  * the attribute header and payload.
@@ -493,6 +495,7 @@ EXPORT_SYMBOL(__nla_put);
  * @attrtype: attribute type
  * @attrlen: length of attribute payload
  * @data: head of attribute payload
+ * @padattr: attribute type for the padding
  *
  * The caller is responsible to ensure that the skb provides enough
  * tailroom for the attribute header and payload.
@@ -551,6 +554,7 @@ EXPORT_SYMBOL(nla_put);
  * @attrtype: attribute type
  * @attrlen: length of attribute payload
  * @data: head of attribute payload
+ * @padattr: attribute type for the padding
  *
  * Returns -EMSGSIZE if the tailroom of the skb is insufficient to store
  * the attribute header and payload.
-- 
2.8.1
