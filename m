From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: fix indentation
Date: Sun, 29 Mar 2015 16:17:37 +0200
Message-ID: <d8d0c5dade7401c4acc2200479025f9f589404b2.1427638583.git.jbenc@redhat.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbbC2OSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 10:18:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some lines in vxlan code are indented by 7 spaces instead of a tab.

Fixes: e4c7ed415387 ("vxlan: add ipv6 support")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 88 ++++++++++++++++++++++++++---------------------------
 1 file changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6080f8e7b0cd..1c80b67c688d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -144,52 +144,52 @@ static struct workqueue_struct *vxlan_wq;
 static inline
 bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
 {
-       if (a->sa.sa_family != b->sa.sa_family)
-               return false;
-       if (a->sa.sa_family == AF_INET6)
-               return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
-       else
-               return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+	if (a->sa.sa_family != b->sa.sa_family)
+		return false;
+	if (a->sa.sa_family == AF_INET6)
+		return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
+	else
+		return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
 }
 
 static inline bool vxlan_addr_any(const union vxlan_addr *ipa)
 {
-       if (ipa->sa.sa_family == AF_INET6)
-               return ipv6_addr_any(&ipa->sin6.sin6_addr);
-       else
-               return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_any(&ipa->sin6.sin6_addr);
+	else
+		return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
 }
 
 static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
 {
-       if (ipa->sa.sa_family == AF_INET6)
-               return ipv6_addr_is_multicast(&ipa->sin6.sin6_addr);
-       else
-               return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_is_multicast(&ipa->sin6.sin6_addr);
+	else
+		return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
 }
 
 static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
 {
-       if (nla_len(nla) >= sizeof(struct in6_addr)) {
-               nla_memcpy(&ip->sin6.sin6_addr, nla, sizeof(struct in6_addr));
-               ip->sa.sa_family = AF_INET6;
-               return 0;
-       } else if (nla_len(nla) >= sizeof(__be32)) {
-               ip->sin.sin_addr.s_addr = nla_get_be32(nla);
-               ip->sa.sa_family = AF_INET;
-               return 0;
-       } else {
-               return -EAFNOSUPPORT;
-       }
+	if (nla_len(nla) >= sizeof(struct in6_addr)) {
+		nla_memcpy(&ip->sin6.sin6_addr, nla, sizeof(struct in6_addr));
+		ip->sa.sa_family = AF_INET6;
+		return 0;
+	} else if (nla_len(nla) >= sizeof(__be32)) {
+		ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+		ip->sa.sa_family = AF_INET;
+		return 0;
+	} else {
+		return -EAFNOSUPPORT;
+	}
 }
 
 static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
-                             const union vxlan_addr *ip)
+			      const union vxlan_addr *ip)
 {
-       if (ip->sa.sa_family == AF_INET6)
-               return nla_put(skb, attr, sizeof(struct in6_addr), &ip->sin6.sin6_addr);
-       else
-               return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+	if (ip->sa.sa_family == AF_INET6)
+		return nla_put(skb, attr, sizeof(struct in6_addr), &ip->sin6.sin6_addr);
+	else
+		return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
 }
 
 #else /* !CONFIG_IPV6 */
@@ -197,36 +197,36 @@ static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
 static inline
 bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
 {
-       return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+	return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
 }
 
 static inline bool vxlan_addr_any(const union vxlan_addr *ipa)
 {
-       return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+	return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
 }
 
 static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
 {
-       return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+	return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
 }
 
 static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
 {
-       if (nla_len(nla) >= sizeof(struct in6_addr)) {
-               return -EAFNOSUPPORT;
-       } else if (nla_len(nla) >= sizeof(__be32)) {
-               ip->sin.sin_addr.s_addr = nla_get_be32(nla);
-               ip->sa.sa_family = AF_INET;
-               return 0;
-       } else {
-               return -EAFNOSUPPORT;
-       }
+	if (nla_len(nla) >= sizeof(struct in6_addr)) {
+		return -EAFNOSUPPORT;
+	} else if (nla_len(nla) >= sizeof(__be32)) {
+		ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+		ip->sa.sa_family = AF_INET;
+		return 0;
+	} else {
+		return -EAFNOSUPPORT;
+	}
 }
 
 static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
-                             const union vxlan_addr *ip)
+			      const union vxlan_addr *ip)
 {
-       return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+	return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
 }
 #endif
 
-- 
1.8.3.1
