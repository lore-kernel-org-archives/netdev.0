From: Harald Welte <laforge@gnumonks.org>
Subject: Re: corruption of ICMP payload while forwarding
Date: Tue, 6 Jul 2004 17:33:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706153313.GM32707@sunbeam2>
References: <20040706122942.GC32707@sunbeam2> <1089124948.1040.2.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h85LGMdA0M9ASxa6"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1089124948.1040.2.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h85LGMdA0M9ASxa6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 06, 2004 at 10:42:29AM -0400, jamal wrote:
> Harald,

Hi Jamal, thanks for your reply.

> I would probably start by downing most of those devices and still see if
> the problem is reproducible with two ethx devices.
> If it is reproducible there then replace the nics with something else
> like tulip or dlinks and see if it still happens there.
> I suspect its a driver issue so if you try the above you can prove it is
> not.

Yes, that was my recommendation, too...   I also recommended disabling
more and more features (i.e. remove iptable_nat, iptable_mangle, ...) to
see if the problem disappears at some point.

However since this is a production machine, I doubt there is too much
room for experimenting.  We're now trying to reproduce this issue with a
seperate box in the lab, though no success so far.

> cheers,
> jamal
--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--h85LGMdA0M9ASxa6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA6sY5XaXGVTD0i/8RAvJzAJ45N7WSkVdQZSmUaGVpNU+f7JGKigCfYsQu
v2yvKuCJonr3PeQhnzWg3p8=
=hwUM
-----END PGP SIGNATURE-----

--h85LGMdA0M9ASxa6--
