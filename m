From: "ZHANG, Le" <r0bertz@gentoo.org>
Subject: Re: [PATCH] ipv4: mitigate an integer underflow when comparing tcp
 timestamps
Date: Fri, 26 Nov 2010 00:55:27 +0800
Message-ID: <20101125165525.GA4480@adriano>
References: <1289720156-30118-1-git-send-email-r0bertz@gentoo.org>
 <1289724745.2743.61.camel@edumazet-laptop>
 <20101114.115536.71112799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101114.115536.71112799.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 11:55 Sun 14 Nov     , David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 14 Nov 2010 09:52:25 +0100
>=20
> > Really, if you have multiple clients behind a common NAT, you cannot use
> > this code at all, since NAT doesnt usually change TCP timestamps.
>=20
> NAT is %100 incompatible with TW recycling, full stop.
>=20
> There is no maybe, or maybe not.
>=20
> If you are behind NAT you must not turn this feature on, ever.

Sorry, this question may be OT on this list, but I am just curious:

Is there any other OS has implemented this feature like Linux?

To be very specific, by this feature, I mean rejecting old duplicates based
on per-host cache of last timestamp received from any connections.
As suggested in RFC1323 Appendix B.2 (b).

Does anyone, by any chance, know the answer? Thanks in advance!

--=20
ZHANG, Le
http://zhangle.is-a-geek.org
0260 C902 B8F8 6506 6586 2B90 BC51 C808 1E4E 2973

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAkzulP0ACgkQvFHICB5OKXOFDwCePUeeQBOqYiZ9rOD431KDYeii
srgAnjkB94rmiHblPYdghTZcttb/JT4B
=76O/
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
