From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: [PATCH] Fix typos in comments in netlink.h
Date: Fri, 5 Oct 2007 08:09:40 +0200
Message-ID: <20071005060940.GA18427@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:37330 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567AbXJEGJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 02:09:41 -0400
Received: from localhost (durga.via.ecp.fr [127.0.0.1])
	by durga.via.ecp.fr (Postfix) with ESMTP id CB0AB31F69
	for <netdev@vger.kernel.org>; Fri,  5 Oct 2007 08:09:40 +0200 (CEST)
Received: from durga.via.ecp.fr ([127.0.0.1])
	by localhost (durga.via.ecp.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id giIEvGnQ1bpt for <netdev@vger.kernel.org>;
	Fri,  5 Oct 2007 08:09:40 +0200 (CEST)
Received: from zen.via.ecp.fr (zen.via.ecp.fr [138.195.130.72])
	by durga.via.ecp.fr (Postfix) with ESMTP id 9B2E731F1C
	for <netdev@vger.kernel.org>; Fri,  5 Oct 2007 08:09:40 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a few typos in comments in include/net/netlink.h

Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 83113df..1afd3e8 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -84,7 +84,7 @@
  *   nla_next(nla)-----------------------------'
  *
  * Data Structures:
- *   struct nlattr			netlink attribtue header
+ *   struct nlattr			netlink attribute header
  *
  * Attribute Construction:
  *   nla_reserve(skb, type, len)	reserve room for an attribute
@@ -706,7 +706,7 @@ static inline int nla_ok(const struct nlattr *nla, =
int remaining)
 }
=20
 /**
- * nla_next - next netlink attribte in attribute stream
+ * nla_next - next netlink attribute in attribute stream
  * @nla: netlink attribute
  * @remaining: number of bytes remaining in attribute stream
  *
@@ -782,7 +782,7 @@ static inline int __nla_parse_nested_compat(struct =
nlattr *tb[], int maxtype,
 ({	data =3D nla_len(nla) >=3D len ? nla_data(nla) : NULL; \
 	__nla_parse_nested_compat(tb, maxtype, nla, policy, len); })
 /**
- * nla_put_u8 - Add a u16 netlink attribute to a socket buffer
+ * nla_put_u8 - Add a u8 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
@@ -998,7 +998,7 @@ static inline struct nlattr *nla_nest_start(struct =
sk_buff *skb, int attrtype)
=20
 /**
  * nla_nest_end - Finalize nesting of attributes
- * @skb: socket buffer the attribtues are stored in
+ * @skb: socket buffer the attributes are stored in
  * @start: container attribute
  *
  * Corrects the container attribute header to include the all
@@ -1041,7 +1041,7 @@ static inline struct nlattr *nla_nest_compat_star=
t(struct sk_buff *skb,
=20
 /**
  * nla_nest_compat_end - Finalize nesting of compat attributes
- * @skb: socket buffer the attribtues are stored in
+ * @skb: socket buffer the attributes are stored in
  * @start: container attribute
  *
  * Corrects the container attribute header to include the all


--=20
Pierre Ynard
=46or hire in Quebec City, Canada, during Fall 2007
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
