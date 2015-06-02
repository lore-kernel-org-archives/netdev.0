From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy
 settings
Date: Tue, 02 Jun 2015 01:57:28 +0100
Message-ID: <1433206648.6319.206.camel@decadent.org.uk>
References: <20150531.171940.1635713770956335110.davem@davemloft.net>
		<1433181931.6319.176.camel@decadent.org.uk>	<556CD197.8070401@broadcom.com>
	 <20150601.144635.1116373189875340733.davem@davemloft.net>
	 <556CF06F.7040402@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mlq7pxCpbKTTegQJhjn2"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
	sbranden@broadcom.com, jdzheng@broadcom.com
To: Arun Parameswaran <aparames@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35032 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750922AbbFBA5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:57:44 -0400
In-Reply-To: <556CF06F.7040402@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mlq7pxCpbKTTegQJhjn2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-06-01 at 16:53 -0700, Arun Parameswaran wrote:
> On 15-06-01 02:46 PM, David Miller wrote:
> > From: Arun Parameswaran <aparames@broadcom.com>
> > Date: Mon, 1 Jun 2015 14:41:43 -0700
> >=20
> >> It would be nice for the 'ethtool' to be flexible to support querying
> >> specific PHY irrespective of the net implementation, but that is being
> >> discussed in the other thread.
> >=20
> > Please stop arguing about this, it isn't valid.
> >=20
> > Your device is a switch, and therefore needs to be represented properly
> > with the proper number of net_device objects.
> >=20
> > Even more importantly, the ethtool API is established and you cannot
> > change these semantics without potentially breaking lots of application=
s
> > and libraries out there.
> >=20
> > Your change is reverted, and I will absolutely not entertain any
> > attempt to again change the semantics of this ethtool operation.
> >=20
> > Thanks.
> >=20
> I apologize if the patch broke any conventions, it was not my intend. I
> understand the implications on other programs that use the interface.
>=20
> Just so that I don=E2=80=99t make this mistake in the future and to under=
stand this
> better, does this mean that the 'phyad' parameter specified in the
> 'ethtool' command line is ignored ?

There are some very old Ethernet cards where the driver can't
automatically detect which PHY address to use, or where the MAC can be
attached to one of several different PHYs.  This is what the 'phyad'
parameter is used for.  I think the only remaining driver that supports
changing the PHY address like this is natsemi.

Ben.

--=20
Ben Hutchings
The obvious mathematical breakthrough [to break modern encryption] would be
development of an easy way to factor large prime numbers. - Bill Gates

--=-mlq7pxCpbKTTegQJhjn2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWz/fOe/yOyVhhEJAQqCdw/+J/Gr9Q4zEkvKdOqqPwPy9GSZ6xKToszR
yrfduA7K6f9jJhGGsjJBztBoLlb4Yx4OvHEPi1n3sF25BPmulP8Dg2fn0+KQheaK
hYyAnj33/AnHduvhkeclvXGIkqxXp5wSCeTZFeCwiEMMogAyuyOR6QZKxDDI3Nk6
pMZNdWsABo/NhfyNIzrv1ifieVROMxubBPs9GdOQc45HNaS9bYzk4n6CwNFNWx/8
SNz3Bu/aeX4g5Sr/VC0JhwFgDt5/I9wuLkbGd878AZdZ+NIjUXVdY52YqwezlyE3
iT5nf62/WVphcQ6bKQlUlhjNVelG45AgKqHbWfg8zT5fx2YrVSWZ+r900DAe6UbC
iAZhTroBRN9HwVrlQYjXTBgzZHTDUVD8hfeooUQJSenuMmX18xWbxra5mFqLK7FI
DUgyAG1WZ9nucffCsjjLC/xPXqSjXEzRJVDuJGIO9PlPdukQIfWiJl+3kuSkGGhE
Nwz6Mes7mQL3YnzwUajmk4KtDcdtjRAH9MH2weemkxrue9qIw7ueM7HM16qe8o4u
vSPJIOst7XNoMBcto4W4zdTs6fiENX9L7w11YY4NFYv0Iginq7nNmyL3JgF2ohZl
qSlXNh5/vVsMOA5ron6x8oKwy6HnUfbf+IHwDJMl6sbmt6869ftZDj/Jlg6FEQZc
x1jnfCtP6XQ=
=WaBF
-----END PGP SIGNATURE-----

--=-mlq7pxCpbKTTegQJhjn2--
