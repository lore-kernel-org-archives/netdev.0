From: kaber@trash.net
Subject: [PATCH 01/37] netfilter: ipset: fix the compile warning in ip_set_create
Date: Tue, 15 Mar 2011 20:43:41 +0100
Message-ID: <1300218257-26953-2-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49416 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab1COTo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:26 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Shan Wei <shanwei@cn.fujitsu.com>

net/netfilter/ipset/ip_set_core.c:615: warning: =E2=80=98clash=E2=80=99=
 may be used uninitialized in this function

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip=
_set_core.c
index 8b1a54c..618a615 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -612,7 +612,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *sk=
b,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
 {
-	struct ip_set *set, *clash;
+	struct ip_set *set, *clash =3D NULL;
 	ip_set_id_t index =3D IPSET_INVALID_ID;
 	struct nlattr *tb[IPSET_ATTR_CREATE_MAX+1] =3D {};
 	const char *name, *typename;
--=20
1.7.2.3

