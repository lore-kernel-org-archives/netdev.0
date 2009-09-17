From: Eric Leblond <eric@inl.fr>
Subject: Re: [ANNOUNCE] new iptables module match large amount of ip
 addresses
Date: Thu, 17 Sep 2009 22:03:37 +0200
Message-ID: <1253217817.21074.9.camel@ice-age>
References: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-H3g82aLcxsv9S0OuloLS"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-H3g82aLcxsv9S0OuloLS
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi,

Le jeudi 17 septembre 2009 =E0 21:15 +0200, Mikulas Patocka a =E9crit :
> Hi
>=20
> Here I submit an iptables module that can match large amounts (millions)=20
> of ip addresses efficiently using binary search.

What are the differences with ipset ? (http://ipset.netfilter.org/)

BR,

>  I needed it to protect my=20
> home network from spam. It may be useful for other people too, so if you=20
> want it, you can take it and add it to the kernel.
>=20
> Get the patches for netfilter and kernel at:
> http://artax.karlin.mff.cuni.cz/~mikulas/xt_ipfile/
> (you need to copy the file include/linux/netfilter/xt_ipfile.h from kerne=
l=20
> sources to /usr/include/linux/netfilter/ to compile the userspace)
>=20
> The main features:
> - fast matching of large amount of ip addresses using binary search.
> - an ability to match ranges of addresses or address/mask subnets.
> - fast loading of the addresses (on Pentium 3 850, 2 million addresses=20
> load in 5.5s, if they are already sorted in the file, the load time is=20
> just 1.5s).
> - memory efficient --- consumes only 8 bytes per address.
>=20
> USAGE:
>=20
> prepare a file with addreses, in this example /root/firewall/bad-ips. One=
=20
> entry per line, the allowed formats are:
> 1.2.3.4
> 1.2.3.0/24
> 1.2.3.4-1.2.3.8
>=20
> insert it into iptables with:
> iptables -A SPAM -m ipfile --src-file /root/firewall/bad-ips -j DROP
>=20
> The module doesn't support ipv6 because I don't use it, but it's generic=20
> enough that it could be extended for it. It could be also extended to=20
> match ethernet MAC addresses.
>=20
> Mikulas
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel=
" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--=20
Eric Leblond <eric@inl.fr>
INL: http://www.inl.fr/
NuFW: http://www.nufw.org/

--=-H3g82aLcxsv9S0OuloLS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Ceci est une partie de message
 =?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKspYWnxA7CdMWjzIRAmdCAJ4r8ajggUeKdq0PKlwW7/Gm+3T9OACfbOGc
KPQLamFjHvXq3FQIO3/lHhE=
=GPlT
-----END PGP SIGNATURE-----

--=-H3g82aLcxsv9S0OuloLS--

