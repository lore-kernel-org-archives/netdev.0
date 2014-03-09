From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header handling
 routines
Date: Sun, 09 Mar 2014 17:59:03 +0000
Message-ID: <1394387943.15968.1.camel@deadeye.wl.decadent.org.uk>
References: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	 <20140304.170050.2058599034902221847.davem@davemloft.net>
	 <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
	 <20140304.172025.2034977449200344617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mYihuwTH0yYwXqVZQeJf"
Cc: phoebe.buckheister@itwm.fraunhofer.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51083 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090AbaCIR7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 13:59:12 -0400
In-Reply-To: <20140304.172025.2034977449200344617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mYihuwTH0yYwXqVZQeJf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-04 at 17:20 -0500, David Miller wrote:
> From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
> Date: Tue, 4 Mar 2014 23:16:31 +0100
>=20
> > I see some value in being able to memcpy() to/from those fields directl=
y
> > when building/reading headers, but I also think that not having to do
> > endianness conversion everywhere for a struct that cannot ever be a val=
id
> > header as is outweighs this.
>=20
> Why have an intermediate copy when that's not necessary at all?  It
> seems like pure overhead to be.
>=20
> Furthermore, cpu's have byte-shifting load and store instructions
> which will be used if you make use of the 'p' versions of the endian
> swap functions, such as cpu_to_le16p().
>=20
> So it's going to cost basically nothing.

The real frame headers don't have naturally aligned fields, so if the
structures are to mirror them they would need to be __packed.  I'm sure
you realise what that does for performance.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-mYihuwTH0yYwXqVZQeJf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxyr5+e/yOyVhhEJAQrMGw//eNw4BoizFtuSc5KSMVUXcgfmNoCc2Hwc
58l8k1AMNt+t6Dl9p5DPaf4zGnxZr0zJa38q149VM/yvShzTLZRLqfHHHPao0niY
/4h+pZgQXEQpubfrOVRCARR56b9eV43AxdLjgafoydJ6RG+Rsm4dvWAsWyGMfM8U
qXo/98UiJ992Dyh4gvWYHewvEdqnYeN3H8M91hONF1losDQ4OCc1gFrlBSrUtnNF
XEdlRKMhlBErohInZt6Rk1GGmD7syF2mIG5IEl6XIAVurxDq6mKjDVEWOwINjz1X
4tQQogtuiKiBQ8go4y61+zm4+hWkG55NrdU2qEDeFEx1ws8SAmeqXnyrItHpKhQA
Y0fFscaYkIOyJKvJyNLFXq7jH4n2li6m2J0UH/kP2qFUjO9MwdUmCdvibCRmnxgq
ZgT39yuv2YB3zrQA1VlRcPupTgKzhpJr5IM0mKRZhp+1d13i+SzniPyHwT+YM7cS
MoG2PhTaH3a+K+LP5z+7lru0jpoi0OLNC0SW1/7iAD0kaHzAob3f4q3Yy8OfuPAc
99x6CIdqQfScDQ1airvSVOyNCCdUfZD0uwKADlFnhVDny72dsiMNki6WS2OGei6r
9sDZ5oIVQZoAzApa7XCY1Qy/ymFnTmli/Sjilv0A9EHVjxd/tMfmgOwVvxRDiWZX
WhGrMnJnk58=
=VCXe
-----END PGP SIGNATURE-----

--=-mYihuwTH0yYwXqVZQeJf--
