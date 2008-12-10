From: Eric Leblond <eric@inl.fr>
Subject: Re: linux-next: Tree for December 1 (netfilter build error)
Date: Wed, 10 Dec 2008 19:43:50 +0100
Message-ID: <1228934630.5961.8.camel@ice-age>
References: <20081201190827.2d02b1a5.sfr@canb.auug.org.au>
	 <20081201115934.00ba918a.randy.dunlap@oracle.com>
	 <20081210165455.GC6391@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UjSN4+bVpf7FFw9CcHSS"
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, kaber@trash.net
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081210165455.GC6391@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UjSN4+bVpf7FFw9CcHSS
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi,

Le mercredi 10 d=E9cembre 2008 =E0 22:24 +0530, Kamalesh Babulal a =E9crit =
:
> * Randy Dunlap <randy.dunlap@oracle.com> [2008-12-01 11:59:34]:
> 	   =20
> the function nfulnl_log_packet is exported only if
> CONFIG_NETFILTER_NETLINK_LOG is enabled, so marking the loging function
> between ifdef.
>=20

My patch introduces a real depedency of xt_NFLOG with nfnetlink_log
(CONFIG_NETFILTER_NETLINK_LOG) but I forget to state it in Kconfig.
=20
I thus disagree with your patch. It is better to fix the compilation
depedency instead by modifying Kconfig.

A patch fixing this issue is to come.

BR,=20
--=20
Eric Leblond <eric@inl.fr>
INL

--=-UjSN4+bVpf7FFw9CcHSS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Ceci est une partie de message
 =?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJQA3gnxA7CdMWjzIRAjimAJ4vFonm+9eIWkFQZCO+WPCGwam1VwCcCSsx
vAn3jMrhqMZDkbzvGr3MZSA=
=KX8/
-----END PGP SIGNATURE-----

--=-UjSN4+bVpf7FFw9CcHSS--

