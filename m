From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: powerpc boot failure
Date: Thu, 8 Apr 2010 17:23:16 +1000
Message-ID: <20100408172316.e6ee451d.sfr@canb.auug.org.au>
References: <20100408165848.38f75f40.sfr@canb.auug.org.au>
	<4BBD81B3.3030500@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__8_Apr_2010_17_23_16_+1000_D7omye96nAmT_nIw"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Timo =?UTF-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4BBD81B3.3030500@iki.fi>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__8_Apr_2010_17_23_16_+1000_D7omye96nAmT_nIw
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, 08 Apr 2010 10:11:47 +0300 Timo Ter=C3=A4s <timo.teras@iki.fi> wrot=
e:
>
> > The above pc is in this piece of code (I think - I don't have the actual
> > kernel) from __xfrm_lookup (in net/xfrm/xfrm_policy.c):
> >=20
> >         if ((flags & XFRM_LOOKUP_ICMP) &&
> >             !(pols[0]->flags & XFRM_POLICY_ICMP)) {
> >                 err =3D -ENOENT;
> >                 goto error;
> >         }
> >=20
> >         for (i =3D 0; i < num_pols; i++)
> >                 pols[i]->curlft.use_time =3D get_seconds(); <-------- (=
line 1845)
> >=20
> > And the 0x200000025 is probably &(pols[i]) (which actually seems unlike=
ly
> > since pols is an array on the stack).
>=20
> What kind of xfrm policies the system has?

I don't even know what an xfrm policy is :-).  This is a pretty normal Ubun=
tu
Gutsy install and wouldn't have anything special in its network setup.

The above code fragment may be not quite the right place, sorry.  But it
is the right function.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__8_Apr_2010_17_23_16_+1000_D7omye96nAmT_nIw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAku9hGQACgkQjjKRsyhoI8wgXQCfaeReplvND7MU7mEqdWjg5BHQ
JcgAn0mk/CV/Tf0rKXMPrw9poFgPbd9K
=19fy
-----END PGP SIGNATURE-----

--Signature=_Thu__8_Apr_2010_17_23_16_+1000_D7omye96nAmT_nIw--
