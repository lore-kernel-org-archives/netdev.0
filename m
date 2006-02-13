From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] 2.6.16: [NETFILTER] Fix Kconfig menu level for x_tables
Date: Mon, 13 Feb 2006 12:06:00 +0100
Message-ID: <20060213110600.GQ4601@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FilwpOHBrTVNlmJ3"
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


--FilwpOHBrTVNlmJ3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply this to the 2.6.16 tree and push it to Linus.

Thanks!

[NETFILTER] Fix Kconfig menu level for x_tables

The new x_tables related Kconfig options appear at the wrong menu level
without this patch.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 2d3e1788278398e3d9f33409066f3232730336a6
tree d23977bfeafb91fdbc5e5400d516ef623cde5a1d
parent 0b2d6ca5297c6343d9ae4c2259f85046e487ed01
author Harald Welte <laforge@netfilter.org> Mon, 13 Feb 2006 12:04:25 +0100
committer Harald Welte <laforge@netfilter.org> Mon, 13 Feb 2006 12:04:25 +0=
100

 net/netfilter/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 99c0a0f..0e55012 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -102,8 +102,6 @@ config NF_CT_NETLINK
 	help
 	  This option enables support for a netlink-based userspace interface
=20
-endmenu
-
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	help
@@ -361,3 +359,5 @@ config NETFILTER_XT_MATCH_TCPMSS
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
+endmenu
+
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--FilwpOHBrTVNlmJ3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD8GgYXaXGVTD0i/8RAmJoAJoC8de1g5p+MkVprIK46nLJlWL15ACfUwYd
spU1w4hFjPBwOmn9JmgQ/r0=
=BTmV
-----END PGP SIGNATURE-----

--FilwpOHBrTVNlmJ3--
