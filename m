From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: NET: Questions about supporting older kernel's with kmods
Date: Thu, 19 Nov 2009 09:59:18 -0500
Message-ID: <4B055D46.6060407@gmail.com>
References: <4B055479.8070101@gmail.com> <1258642393.2837.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE308AAB0D08EA3D53A0CD144"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756849AbZKSO7S@vger.kernel.org>
In-Reply-To: <1258642393.2837.5.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE308AAB0D08EA3D53A0CD144
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Ben Hutchings wrote:
> On Thu, 2009-11-19 at 09:21 -0500, Gregory Haskins wrote:
[...]
>=20
>> or should I simply look at the kernel version?
>=20
> That works up to a point, but the 'enterprise' distros backport a lot t=
o
> earlier kernel versions which can make version tests invalid.

Good point

>=20
> Some out-of-tree/backported drivers use autoconf-style tests, but there=

> is no standard way of doing this.
>=20

Yeah, this might be the only sane way.  It turns out that my ETHTOOL
issue was trivial.  I was missing "#include <linux/ethtool.h>" which
worked in upstream, but not in older kernels.  So that issue is resolved.=


Now I just need to figure out netdev_ops.  Perhaps I will just patch the
netdev_ops out when building a kmod, since its just
a different way to describe the same thing, and the resulting driver
will perform the same.

> =EF=BB=BF[...]
>> Q2) Is it considered "bad form" to include such compile-time directive=
s
>> in the version of the code going upstream?
> [...]
>=20
> Yes.  Don't do that.

Ok.

Thanks Ben,
-Greg


--------------enigE308AAB0D08EA3D53A0CD144
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksFXUYACgkQP5K2CMvXmqGtxwCfQnxSt+62yv2eZaKOd9viBfAW
0LkAn2CJeEM8qjs6wGU/iiMczBeld1I5
=xy/f
-----END PGP SIGNATURE-----

--------------enigE308AAB0D08EA3D53A0CD144--
