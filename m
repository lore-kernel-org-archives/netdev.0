From: Valdis.Kletnieks@vt.edu
Subject: XT_MATCH_REALM Kconfig whinge...
Date: Wed, 12 Jan 2011 14:15:15 -0500
Message-ID: <20519.1294859715@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1294859715_4778P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1294859715_4778P
Content-Type: text/plain; charset=us-ascii

I think I posted about this a long ways back, still seeing it in yesterday's linux-next:

scripts/kconfig/conf --silentoldconfig Kconfig
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)

(NET is of course set, NET_SCHED isn't).

--==_Exmh_1294859715_4778P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNLf3DcC3lWbTT17ARAkv7AJ9npRmZcvO5kl/lQNBNaDxcjCsKAQCcCxJR
t2cc2/jjFQMsH4mJW0xcStw=
=sfka
-----END PGP SIGNATURE-----

--==_Exmh_1294859715_4778P--

