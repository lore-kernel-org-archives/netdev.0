From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net V1] ethtool: Support for configurable RSS hash
 function
Date: Sun, 31 May 2015 21:06:01 +0100
Message-ID: <1433102761.6319.111.camel@decadent.org.uk>
References: <1430133773-11613-1-git-send-email-amirv@mellanox.com>
	 <CAPcc5PigfcBCZV=z+Q15+0xBXh_GEyGEz6RASPCXtQvTXadP0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3E+I+rIq8X+pN9JKFgrg"
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58567 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbbEaUGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 16:06:14 -0400
In-Reply-To: <CAPcc5PigfcBCZV=z+Q15+0xBXh_GEyGEz6RASPCXtQvTXadP0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3E+I+rIq8X+pN9JKFgrg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-05-05 at 18:48 +0300, Amir Vadai wrote:
> On Mon, Apr 27, 2015 at 2:22 PM, Amir Vadai <amirv@mellanox.com> wrote:
> > From: Eyal Perry <eyalpe@mellanox.com>
> >
> > This ethtool patch adds support to set and get the current RSS hash
> > function for the device through through the new hfunc field in the
> > ethtool_rxfh struct. Kernel supported hash function names are queried
> > with ETHTOOL_GSTRINGS (value 0 is reserved and skipped).
> >
> > Although currently no device supports a combination of hash
> > functions/attributes, this ethtool implementation will support it. Both=
 in the
> > set and in the get.
> > The device driver declares the functions and/or attributes that it supp=
orts,
> > and ethtool will show it correctly and enable the user to set those
> > combinations.
> > If a combination is not supported - the device driver will fail the ope=
ration
> > and ethtool will print an error message.
> >
> > Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> > Changes from V1:
> > - Fixed some English mistakes
> > - Fixed the complicated way to write '=3D req_hfunc;'...
> > - Better support in combination of hash functions/attributes
>=20
> Ben Hi,
>=20
> Could you take a look at this patch?

Didn't we agree that only one hash function should be selected at once?
Can you send a new version that implements that?

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-3E+I+rIq8X+pN9JKFgrg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWtprue/yOyVhhEJAQpwgg//WfaqkJplQPEVCiA4qlGi9AiEFgXyYt5k
iJdZOxkFEA502vIy3321oczn+wmeDVy1f5Bs3v/kF/0hcQlEaAlK1qUpZDS0Kl+I
xNsDs83HQbk+7lU24iaHFLajEiK8B4nzKhFiOKGciSyHEO+VwAbVIhJSpaRLFDyP
NO0bsFDISC0bF9UcFrRwedfhVbyEDxcrHVhoGA6tbIzgbN4PJdmzPAtshgDxzKUs
V1VxhvsggRMz0r/+1c4Rc41PK8sAYOpvx2UxSNCY7JqtwIJV1ocrmOyyKR91ce97
g7nlnf2Xeq3G5lnS+2hRx5tZl1ZyumePQxUMlKApmkQ4RwO7T9f4AVGwAJY6TPe0
BJVZmEI2vkIGyExycA2XfyAOOJ5vuXuyCfFUecZsyfwrjMiO6JGLCrAZoEACpn/A
V8LJ12y1lzt0PdAH2AhTL89bN/hSSdr/Q7lGKHlEh1u3Y9DO8BaTjFVIMWmgL33M
ovi8fBc05ovkQCx0P14rB+jMIoJi9gqLwtwr5OVYG3ilGF+EF8BPEE7K+yvZeBsJ
xsDdYP/oaFVfYb7JaVbXYmRr3rmNLSy/07A5J451Z7JK4aIqnIxWZVBSB5RGnB5K
8G2dk2Mda6BFIfM/o3qYpGXvyw2Yx/KJ1yrbPd0VWdZTfU/R3+US9vsEknOLNlAF
p3mUb5MVfBs=
=cZ/K
-----END PGP SIGNATURE-----

--=-3E+I+rIq8X+pN9JKFgrg--
