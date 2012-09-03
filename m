From: pablo@netfilter.org
Subject: [PATCH 19/25] netfilter: xt_socket: fix compilation warnings with gcc 4.7
Date: Tue,  4 Sep 2012 01:54:06 +0200
Message-ID: <1346716452-3080-20-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37169 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756600Ab2ICX4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:04 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes compilation warnings in xt_socket with gcc-4.7.

In file included from net/netfilter/xt_socket.c:22:0:
net/netfilter/xt_socket.c: In function =E2=80=98socket_mt6_v1=E2=80=99:
include/net/netfilter/nf_tproxy_core.h:175:23: warning: =E2=80=98sport=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:265:16: note: =E2=80=98sport=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:23: warning: =E2=80=98dport=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:265:9: note: =E2=80=98dport=E2=80=99 was decl=
ared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:6: warning: =E2=80=98saddr=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:264:27: note: =E2=80=98saddr=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:6: warning: =E2=80=98daddr=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:264:19: note: =E2=80=98daddr=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
net/netfilter/xt_socket.c: In function =E2=80=98socket_match.isra.4=E2=80=
=99:
include/net/netfilter/nf_tproxy_core.h:75:2: warning: =E2=80=98protocol=
=E2=80=99 may be used uninitialized in this function [-Wmaybe-uninitial=
ized]
net/netfilter/xt_socket.c:113:5: note: =E2=80=98protocol=E2=80=99 was d=
eclared here
In file included from include/net/tcp.h:37:0,
                 from net/netfilter/xt_socket.c:17:
include/net/inet_hashtables.h:356:45: warning: =E2=80=98sport=E2=80=99 =
may be used uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/xt_socket.c:112:16: note: =E2=80=98sport=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:106:23: warning: =E2=80=98dport=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:112:9: note: =E2=80=98dport=E2=80=99 was decl=
ared here
In file included from include/net/tcp.h:37:0,
                 from net/netfilter/xt_socket.c:17:
include/net/inet_hashtables.h:356:15: warning: =E2=80=98saddr=E2=80=99 =
may be used uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/xt_socket.c:111:16: note: =E2=80=98saddr=E2=80=99 was dec=
lared here
In file included from include/net/tcp.h:37:0,
                 from net/netfilter/xt_socket.c:17:
include/net/inet_hashtables.h:356:15: warning: =E2=80=98daddr=E2=80=99 =
may be used uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/xt_socket.c:111:9: note: =E2=80=98daddr=E2=80=99 was decl=
ared here
In file included from net/netfilter/xt_socket.c:22:0:
net/netfilter/xt_socket.c: In function =E2=80=98socket_mt6_v1=E2=80=99:
include/net/netfilter/nf_tproxy_core.h:175:23: warning: =E2=80=98sport=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:268:16: note: =E2=80=98sport=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:23: warning: =E2=80=98dport=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:268:9: note: =E2=80=98dport=E2=80=99 was decl=
ared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:6: warning: =E2=80=98saddr=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:267:27: note: =E2=80=98saddr=E2=80=99 was dec=
lared here
In file included from net/netfilter/xt_socket.c:22:0:
include/net/netfilter/nf_tproxy_core.h:175:6: warning: =E2=80=98daddr=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
net/netfilter/xt_socket.c:267:19: note: =E2=80=98daddr=E2=80=99 was dec=
lared here

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_socket.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 9ea482d..63b2bdb 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -108,9 +108,9 @@ socket_match(const struct sk_buff *skb, struct xt_a=
ction_param *par,
 	const struct iphdr *iph =3D ip_hdr(skb);
 	struct udphdr _hdr, *hp =3D NULL;
 	struct sock *sk;
-	__be32 daddr, saddr;
-	__be16 dport, sport;
-	u8 protocol;
+	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
+	__be16 uninitialized_var(dport), uninitialized_var(sport);
+	u8 uninitialized_var(protocol);
 #ifdef XT_SOCKET_HAVE_CONNTRACK
 	struct nf_conn const *ct;
 	enum ip_conntrack_info ctinfo;
@@ -261,9 +261,9 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_=
action_param *par)
 	struct ipv6hdr *iph =3D ipv6_hdr(skb);
 	struct udphdr _hdr, *hp =3D NULL;
 	struct sock *sk;
-	struct in6_addr *daddr, *saddr;
-	__be16 dport, sport;
-	int thoff =3D 0, tproto;
+	struct in6_addr *daddr =3D NULL, *saddr =3D NULL;
+	__be16 uninitialized_var(dport), uninitialized_var(sport);
+	int thoff =3D 0, uninitialized_var(tproto);
 	const struct xt_socket_mtinfo1 *info =3D (struct xt_socket_mtinfo1 *)=
 par->matchinfo;
=20
 	tproto =3D ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
--=20
1.7.10.4
