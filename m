From: =?iso-8859-1?Q?Gu=F0mundur_D=2E?= Haraldsson <gdh@binhex.EU.org>
Subject: Re: IPv6 kernel ooops
Date: Sun, 25 Apr 2004 02:14:07 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040425021407.GA11856@binhex.EU.org>
References: <20040424222340.GA10595@binhex.EU.org> <20040425.104217.31070133.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>
Content-Disposition: inline
In-Reply-To: <20040425.104217.31070133.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

-*- YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@wide.ad.jp> [ 2004-04-25 01:4=
3 ]:
> In article <20040424222340.GA10595@binhex.EU.org> (at Sat, 24 Apr 2004 22=
:23:41 +0000), Gu=F0mundur D. Haraldsson <gdh@binhex.EU.org> says:
>=20
> > I got this oops on my machine tonight.
> >
> > I don't know what query to BIND caused it, but I've got an oops like th=
is before!
>=20
> Is this reproducable? How frequently do you see this?

I belive this is hard to reproduce, I had this once some months ago.

>=20
>=20
> > Call Trace:   [<c02112f0>] output_maybe_reroute [kernel] 0x0 (0xc39d9d0=
c)
>=20
> (Umm, I cannot find "output_maybe_reroute" in my source...)
>=20
> > [<c68e2df1>] udpv6_sendmsg [ipv6] 0x271 (0xc39d9d3c)
> > [<c68e2a90>] udpv6_getfrag [ipv6] 0x0 (0xc39d9d44)
> :

Dunno... it's a RedHat kernel... some patch maybe?

>=20
> Would you test latest rc (or bk tree), please?

Well... I need a test-case first...


Best regards,
-Gudmundur.

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
| Gu=F0mundur D. Haraldsson               | When you have eliminated the im=
possible,|
| gdh@binhex.EU.org                     | what ever remains, however improb=
able,  |
| http://www.binhex.EU.org/             | must be the truth.			  |
|                                       | - Sherlock Holmes, "The sign of f=
our"	  |
|--------------------------------------------------------------------------=
-------|
| GPG key: lynx -dump http://vlug.eyjar.is/gdh/gpgkey.asc | gpg --import   =
       |
| Key fingerprint =3D DE6D A875 EA92 0699 9B49  8C49 2DBB 76BF ADD4 C933		 =
 |
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
// Spammers will be asphyxiated in pat=E9!

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAix7vLbt2v63UyTMRAl4mAJ9b4XWLsgnu6ZLrbtA92UMd1Nm7wQCfbtM4
ZmKdhWCpkQa8qtSmkPt1DiI=
=14db
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
