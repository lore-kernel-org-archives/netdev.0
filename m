From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 1/2] netfilter Kconfig dependency fix
Date: Sat, 17 Sep 2005 18:16:40 +0200
Message-ID: <20050917161639.GB8413@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zinZTyJ7Pquq9iCB"
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


--zinZTyJ7Pquq9iCB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.


[NETFILTER] Solve Kconfig dependency problem

As suggested by Roman Zippel.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 95ef9808bc0702757a40886aed48a6fc03aee47b
tree 03b0cca73e6c7f686702c52291e9eb786bb8f02a
parent 1d21ab174ffeba8e709966dc60e57524553adb84
author Harald Welte <laforge@netfilter.org> Sa, 17 Sep 2005 17:22:53 +0200
committer Harald Welte <laforge@netfilter.org> Sa, 17 Sep 2005 17:22:53 +02=
00

 net/ipv4/netfilter/Kconfig |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -8,7 +8,6 @@ menu "IP: Netfilter Configuration"
 # connection tracking, helpers and protocols
 config IP_NF_CONNTRACK
 	tristate "Connection tracking (required for masq/NAT)"
-	select NETFILTER_NETLINK if IP_NF_CONNTRACK_NETLINK!=3Dn
 	---help---
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
@@ -55,8 +54,7 @@ config IP_NF_CONNTRACK_EVENTS
 config IP_NF_CONNTRACK_NETLINK
         tristate 'Connection tracking netlink interface'
         depends on IP_NF_CONNTRACK && NETFILTER_NETLINK
-	default IP_NF_CONNTRACK if NETFILTER_NETLINK=3Dy
-	default m if NETFILTER_NETLINK=3Dm
+	depends on IP_NF_CONNTRACK!=3Dy || NETFILTER_NETLINK!=3Dm
         help
           This option enables support for a netlink-based userspace interf=
ace
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--zinZTyJ7Pquq9iCB
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDLEFnXaXGVTD0i/8RAtrRAKCalMomelUaFUukVqlcwU4JgCZHmwCfR231
ltS/fAW/LSDPpR89yNqWlac=
=XaIG
-----END PGP SIGNATURE-----

--zinZTyJ7Pquq9iCB--
