From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 05 Feb 2014 10:23:40 +0000
Message-ID: <1391595820.3003.60.camel@deadeye.wl.decadent.org.uk>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
	 <1391526492.7871.8.camel@e37108.spectralink.com>
	 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>
	 <20140205071250.GA4071@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Pm0xVBXcKJWtAtqN8/Ja"
Cc: =?ISO-8859-1?Q?S=F8rensen=2C?= Stefan
	<Stefan.Sorensen@spectralink.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54168 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbaBEKYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 05:24:04 -0500
In-Reply-To: <20140205071250.GA4071@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Pm0xVBXcKJWtAtqN8/Ja
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-05 at 08:12 +0100, Richard Cochran wrote:
> On Tue, Feb 04, 2014 at 09:51:59PM +0000, Ben Hutchings wrote:
> >=20
> > Right.  If all versions of CPSW include hardware timestamping then
> > bother with PHY timestamping at all?  And why make CONFIG_TI_CPTS
> > configurable?
>=20
> On the one hand, PHY time stamping is more accurate and offers
> synchronization performance that is measurably better than MAC time
> stamping.

I suppose that depends on how much jitter there is in the PHY?

With SFC boards and 10GBASE-SR modules or DA cables, I would see
synchronisation to within about 10 nanoseconds using MAC timestamps.

> On the other hand, when using a MAC the CPU usually has much
> more direct access to the clock (for example, direct register access
> or PCIe, versus MDIO).
>=20
> I once worked on a project in which it was planned to have both kinds
> of hardware in the design, in order to keep our options open in the
> face of fluid requirements. So I think you can expect to see such
> combinations in the wild, especially in the embedded area.
>=20
> We cannot reasonably support both types in the kernel at the same
> time, and so it makes sense to have compile time options in MAC
> drivers to disable time stamping.

I would think that it should be a *run-time* option, as I don't like
forcing people to rebuild their kernel.  But perhaps this is esoteric
enough that the people who care will be doing that anyway.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-Pm0xVBXcKJWtAtqN8/Ja
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvIRLOe/yOyVhhEJAQrIaA/+NJ9jQJksXLGhS/mkKxWigvJ9a8QFiaYL
PgjqpJStUIpp+jVJ8uM2iazUY647dSV1ydqvMLkHPEI46NUvAaH8R8PbOm/EMIPP
MF1WvfzLDu+uFxiQI/yAOgEq5V8AfKSxyASPVG6JzAzhyV0adg0Lhjv2TE14IE9V
+QFVdgsrMvUyHyoTMq0+jmM7X0WRt44dYr3tFEIt87upn7kYl4OTaMwxB1iaKnGa
7bGHsPwL6lZlFR2MyMfFei0M/mI3nQuVLRtWlcwc82hyswhDMVhCUNj8etHenKX7
R0/CooiB1QE0dyQUp91kdRr98r0bsrlXy5/0Zs03w6V3m5xWlidtIkOw8khoVA+t
BJFnpyc8v/hB28ENgMr+tg6KxgR+YrEzGxHh7Yr+ylaS8bd4nPLeWBfvC4G/g71h
tvqcH91mZCq6KgMqXDkl9CktVGO35t7z+jYvHuVCKnoGVqR+oDHCgvCrdha3D6hT
qM4vgkq9Coz8Ed4Zb80A7C/im1AYGth21+5lVBJ7WgmDHXLRr88huJ1Lmp4Hfw9l
BrYhApviCYVWHJTMmmUAMEc/oJ0j7uIoYC0CusYU3KJjQPm9mr/TaGVmTQj0PphS
aERVigvBlSbDi+iUMeyZTdzbzZTD0KnuTAfz0j+290lXrspCLLHqMGRkVhCrQNYS
gB1sv8VkcV8=
=C7Zn
-----END PGP SIGNATURE-----

--=-Pm0xVBXcKJWtAtqN8/Ja--
