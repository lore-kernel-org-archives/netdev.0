From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ctnetlink: fix typo in ctnl_exp_cb array
Date: Fri, 5 Aug 2005 18:21:42 +0200
Message-ID: <20050805162142.GA4033@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mYCpIKhGyMATD0i+"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.

[NETFILTER] Fix typo in ctnl_exp_cb array (no bug, just memory waste)

This fixes the size of the ctnl_exp_cb array that is IPCTNL_MSG_EXP_MAX
instead of IPCTNL_MSG_MAX. Simple typo.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 76596b57e2fe552da8beef4a59d5b559dfc3d0e5
tree 84acf2c3953dd3b824cfdb0b501e1b778ac2de19
parent cc45a2a7c15b72bf38d611e469fa30d62ade8f1f
author Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:23:56 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:23:56 +02=
00

 net/ipv4/netfilter/ip_conntrack_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_netlink.c b/net/ipv4/netfilter=
/ip_conntrack_netlink.c
--- a/net/ipv4/netfilter/ip_conntrack_netlink.c
+++ b/net/ipv4/netfilter/ip_conntrack_netlink.c
@@ -1490,7 +1490,7 @@ static struct nfnl_callback ctnl_cb[IPCT
 					    .cap_required =3D CAP_NET_ADMIN },
 };
=20
-static struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_MAX] =3D {
+static struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_EXP_MAX] =3D {
 	[IPCTNL_MSG_EXP_GET]		=3D { .call =3D ctnetlink_get_expect,
 					    .attr_count =3D CTA_EXPECT_MAX,
 					    .cap_required =3D CAP_NET_ADMIN },
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--mYCpIKhGyMATD0i+
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC85IVXaXGVTD0i/8RAo6bAJ4nyKzPawn9Z7wdQaakuoyLUTrtAACfQmqY
nYOpPXLg8ItZ8PJzKgYAtdY=
=pwIB
-----END PGP SIGNATURE-----

--mYCpIKhGyMATD0i+--
