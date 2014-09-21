From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v7 ethtool 2/2] ethtool: Support for configurable RSS
 hash key
Date: Sun, 21 Sep 2014 23:15:28 +0100
Message-ID: <1411337728.20019.26.camel@decadent.org.uk>
References: <1406031667-30364-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <7ea09e91-8845-4e2a-b69a-3796b0825664@CMEXHTCAS1.ad.emulex.com>
	 <1411332751.20019.24.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GU8sJ6XRrE/kwazls9b2"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33267 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751506AbaIUWPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 18:15:51 -0400
In-Reply-To: <1411332751.20019.24.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GU8sJ6XRrE/kwazls9b2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-09-21 at 21:52 +0100, Ben Hutchings wrote:
> On Tue, 2014-07-22 at 17:51 +0530, Venkat Duvvuru wrote:
> > This ethtool patch will primarily implement the parser for the options =
provided
> > by the user for get and set rxfh before invoking the ioctl.
> > This patch also has
> > 1. Ethtool man page changes which describes the Usage of
> >    get and set rxfh options.
> > 2. Test cases for get and set rxfh in test-cmdline.c
> >=20
> > Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> [...]
>=20
> FAIL: test-cmdline
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> E: ethtool --rxfh devname hkey foo returns 0
> E: ethtool -X devname hkey foo returns 0
>=20
> The problem with these test cases is we can't parse the hash key (and
> reject "foo") until after we start sending ioctls.  test-cmdline doesn't
> include any mocking of ioctls, but instead makes each test successful if
> it calls an ioctl.

It also doesn't work for me with an older kernel version (I tested on
Linux 3.14).  I don't know why that is, as your fallback code does look
reasonable.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camu=
s

--=-GU8sJ6XRrE/kwazls9b2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVB9OD+e/yOyVhhEJAQrg2xAAmuVUweoTgYrfdHI4mXZAoauhJl3Hz09c
7vxb4lL2B7DeTTz3Gokbi1KzVf61pwD5tOuO6Rrh2mVv5uehnsWL2lfBFzaHY3CJ
Ogv96AYTJfwt0yeSHoq0vTIn9Sj8opmwqki77Y8kwtx7oWK2kgTLLHVTobqgHvIW
w0qZO4PsLtTSSxa5uVgiG/CycNFLZAbD/sqLdnDfz5KrKIleaF2Sx+iH/vzwUqQu
Zj0SZexx4eY3FR+VMjTz/1pTtfNO23xFouLBfxK/SS6t5osqhKKF07fiwgP97hYv
z8C9Vg2/yklhgrQS37biQ44O9sYk5gjeYmmPD9vKPEPbAD4i492F81vmyRHBezAv
81O1bdjIY5P8+rcMqV7InqQx6WPz7FDQr0//MjBW/G8fqiXukuwrEAN/cl9vtOF5
oXjP5bvx/m0yqFGMmBhpvafZm5/+IHxVwriqnM3HYVYgaicVPZ3vmwPSvE7Uff8a
cYQGbTmBrFjjjYA9fSYs7I3o2om6ku2s3M7lKZi6xx2FybHKl7gBidIVNZV+cgyy
NFNFffvWUuhYsplOkB49tOvqsQ11JjnprJ/o0O2TaGVY9aM97jTipwUawumC0xEs
+JbTIkXmTXcVpVodi9ukM6ZRID07uX2wGag6IUGiT1LKuCShuKSfludkZtFvK2YD
fUEbCiKZyHQ=
=n41C
-----END PGP SIGNATURE-----

--=-GU8sJ6XRrE/kwazls9b2--
