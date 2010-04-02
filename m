From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Fri, 02 Apr 2010 16:51:08 +0100
Message-ID: <1270223468.12516.138.camel@localhost>
References: <1270096441.12516.18.camel@localhost>
	 <1270141428.3101.399.camel@macbook.infradead.org>
	 <20100401180511.GQ16821@decadent.org.uk>
	 <20100401.193810.172601735.davem@davemloft.net>
	 <1270206895.3101.2467.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Gvkj0XIz+0mRTQXclmgn"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	553024@bugs.debian.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41757 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751279Ab0DBPvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 11:51:20 -0400
In-Reply-To: <1270206895.3101.2467.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Gvkj0XIz+0mRTQXclmgn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-04-02 at 12:14 +0100, David Woodhouse wrote:
> On Thu, 2010-04-01 at 19:38 -0700, David Miller wrote:
> > Whatever you submit
> > next I'd like to toss into net-next-2.6 so it can cook for a while
> > and maybe we'll backport it so that this bug can be fixed for good
> > upstream and then perhaps even in -stable.=20
>=20
> When backporting, note that you'll need s/PHY_ID_BCMAC131/0x0143bc70/ in
> the patch to broadcom.c, because 2.6.32 didn't have a definition for
> that.
>=20
> There's also trivial change in phy_device_create() which will make the
> patch fail to apply, but git-cherry-pick copes.

Thanks again, David.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-Gvkj0XIz+0mRTQXclmgn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS7YSXee/yOyVhhEJAQJeAhAA1WtWs1Zfwqrw2bVF1Lin5Rh8XctOJNTh
3yPzrTMOrm/Z+ujHXiCn+RWVooqM0Ae2uvGa+dCIcKKzNZ0eFxm40ZNmunSHVPyy
gjD8Nm2MUv0vXBscU/Gx3Ft3Qurid48EvRU2xlqNNEPTn/oxkOED1OlyBREc+VwA
N7KQhnhRq3iwlukF1wKOPBV/jWCHqKwNiCMK2H3NROS9Wp9ueIpptW/TqFuxjMxx
wLz2fFdmGTIaTaWUEdw+t5R+x7mmRQ+UQ5TJ8v4X5qd7jBxQwmqslKu1r0pBSuKR
OwDzJagY2yikDlkKQcY3EroajTI8ubenUgS6v5DGZoc/nSSWq2KDg3VqXT405nwS
WvboH4wORXgU6tTTcdd69E6RF77Hd4baCfoyNQdRVaXQXvlxoRlWKxt/wT8kN24l
7f/i7Z3FieGHpjgUgeCoZv6CUx0wfHvmwgvSciOwJLDdjs19KbRcVQBf0URi+tlE
3UULoslVRxRiJrG+vMyGjlFZr+wRvPZmIlQ2t0H9tn+oOL6VUnz7sJqyaPxG2k3D
QB8af03zStsPZXwzns+8Iz0jyEg3UnlRCZHR9QjT7BpiObiDSUSUHI8Glf62J9jS
C5jyoioFHHz4BodyXQglGVvzW05B0wgI8zRwi+0aDLGK24tLe7ggqlLA/BGHDHYz
VPM5xsaZF7Y=
=U7KC
-----END PGP SIGNATURE-----

--=-Gvkj0XIz+0mRTQXclmgn--
