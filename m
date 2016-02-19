From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Fri, 19 Feb 2016 01:20:48 +0000
Message-ID: <1455844848.2794.61.camel@decadent.org.uk>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	 <1455839111.2794.51.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B3871@CHN-SV-EXMX02.mchp-main.com>
	 <1455840387.2794.59.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B389F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rNHQ7XQZU/tIZ9fxOR96"
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55935 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1947990AbcBSBVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 20:21:05 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404B389F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rNHQ7XQZU/tIZ9fxOR96
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-19 at 00:16 +0000, Woojung.Huh@microchip.com wrote:
> > > Ben, thanks for comments.
> > > How about comment in include/uapi/linux/ethtool.h?
> > > It says
> > > ** struct ethtool_pauseparam - Ethernet pause (flow control) paramete=
rs
> > > ...
> > > * If @autoneg is non-zero, the MAC is configured to send and/or
> > > * receive pause frames according to the result of autonegotiation.
> > >=20
> > > Doesn't this mean get_pauseparam() returns pause settings based on
> > > Result of autonegotation? Not manual settings of rx_param & tx_param?
> >=20
> > No, get_pauseparam should return the same settings that were passed to
> > the last set_pauseparam.
> >=20
> > Ben.
>=20
> I used drivers/net/ethernet/intel/e1000e driver as reference.
> It's implementation also returns status updated after autonegotiation.
> Look into wrong one?

Unfortunately the API has not always been clearly defined and there are
lots of bugs (or at least inconsistencies) in drivers.  The comments in
include/uapi/linux/ethtool.h are supposed to be definitive; if they are
not clear then please suggest additional or alternative wording.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-rNHQ7XQZU/tIZ9fxOR96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsZt8Oe/yOyVhhEJAQo0hg/+Omru8MArLkBFcIPX7qlCY+biomX6A4p1
V/av5n9eyy/IR9KAnJHKn+KxJrSnd7u67zZiL4UfSX+3u3zixJBIKNDmrpzHqUIZ
zuAuET8e0LgMnSa/LRxDcuANj1jPQkUbqaVtZqxRGmjN0FTNrnTp/5ij4inFMw8Z
FafIaauUBAxHRSjOM/tlM3xXJS6PPbZhydwnT6iTr+aimtY9s5MYZBxc0xMM4OVb
QxY6aemeMUDRd2twM5FS3rJ1sZXJrUXnRoDijyywcqEbDAnsd9YcYqqELuUVo2on
DXHVd2BD60PWbKEoUctVMUIJYx/keRV6uFUn75c7RUGXVO8Pw9mQZ9yzSjqNzDnV
RwGur78iepos0nEJvR1pTzcFPZj8YaezjgsxtV5bTIDebTI5iqONCGtAzz8VAE5+
n05gkqV4uErcWfZczQQe216LhvD1AevWbYOiqwmS+BY4/EIT1t1985/KArZc9AtO
rRW/3IHjIHGSkiQ+TrOOlfGmV8zt03okKutb+wZF8ogo4lHKg4kOyHJWnk1j+b5R
NRyt3jFfntcVUwtOJkEPSTdf8PP+ukKilxIBsbRTWCELYsJ6RZHpNO1szW1s7mGD
lrcuxw1lhsgZvZmKU7lYDSiWPzWuPg0CCSxsHx6C3EZQFCVvycnSrYieKYyGvlLB
GuLVcv2Q8+4=
=O3qN
-----END PGP SIGNATURE-----

--=-rNHQ7XQZU/tIZ9fxOR96--
