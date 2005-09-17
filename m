From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2/2] netfilter Kconfig whitespace cleanup
Date: Sat, 17 Sep 2005 18:17:26 +0200
Message-ID: <20050917161726.GC8413@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0MC1Z9bqFMhiUToQ"
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	Linux Netdev List <netdev@vger.kernel.org>,
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


--0MC1Z9bqFMhiUToQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.


[NETFILTER] Kconfig whitespace cleanup

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 49d4c50fa9b5ee5a718c2a38e28b6dd99fd65c62
tree d06a6a7421369f5e63e6ce7130ab11e9202471ce
parent 95ef9808bc0702757a40886aed48a6fc03aee47b
author Harald Welte <laforge@netfilter.org> Sa, 17 Sep 2005 17:24:18 +0200
committer Harald Welte <laforge@netfilter.org> Sa, 17 Sep 2005 17:24:18 +02=
00

 net/ipv4/netfilter/Kconfig |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -52,11 +52,11 @@ config IP_NF_CONNTRACK_EVENTS
 	  IF unsure, say `N'.
=20
 config IP_NF_CONNTRACK_NETLINK
-        tristate 'Connection tracking netlink interface'
-        depends on IP_NF_CONNTRACK && NETFILTER_NETLINK
+	tristate 'Connection tracking netlink interface'
+	depends on IP_NF_CONNTRACK && NETFILTER_NETLINK
 	depends on IP_NF_CONNTRACK!=3Dy || NETFILTER_NETLINK!=3Dm
-        help
-          This option enables support for a netlink-based userspace interf=
ace
+	help
+	  This option enables support for a netlink-based userspace interface
=20
=20
 config IP_NF_CT_PROTO_SCTP
@@ -192,8 +192,8 @@ config IP_NF_MATCH_PKTTYPE
 	tristate "Packet type match support"
 	depends on IP_NF_IPTABLES
 	help
-         Packet type matching allows you to match a packet by
-         its "class", eg. BROADCAST, MULTICAST, ...
+	  Packet type matching allows you to match a packet by
+	  its "class", eg. BROADCAST, MULTICAST, ...
=20
 	  Typical usage:
 	  iptables -A INPUT -m pkttype --pkt-type broadcast -j LOG
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--0MC1Z9bqFMhiUToQ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDLEGWXaXGVTD0i/8RApENAJ45l0XOc7U/SkAsJasTwIBZBlVXXACeL9AA
weeTkpZdTHbmsWjPGgOedMI=
=wMrp
-----END PGP SIGNATURE-----

--0MC1Z9bqFMhiUToQ--
