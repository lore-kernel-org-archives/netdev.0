From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH 2/7] ixgbe: remove unused #define
Date: Thu, 12 Jul 2012 11:15:38 -0700
Message-ID: <1342116938.1783.57.camel@jtkirshe-mobl>
References: <1341959492-31389-1-git-send-email-jdmason@kudzu.us>
	 <1341959492-31389-2-git-send-email-jdmason@kudzu.us>
	 <1341960208.3336.43.camel@jtkirshe-mobl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WmKfEnkVjb2fYf4OVnMI"
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341960208.3336.43.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WmKfEnkVjb2fYf4OVnMI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-10 at 15:43 -0700, Jeff Kirsher wrote:
> On Tue, 2012-07-10 at 15:31 -0700, Jon Mason wrote:
> > Remove unused IXGBE_INTEL_VENDOR_ID #define
> >=20
> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Cc: Bruce Allan <bruce.w.allan@intel.com>
> > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > Cc: Don Skidmore <donald.c.skidmore@intel.com>
> > Cc: Greg Rose <gregory.v.rose@intel.com>
> > Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Cc: Alex Duyck <alexander.h.duyck@intel.com>
> > Cc: John Ronciak <john.ronciak@intel.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    3 ---
> >  1 file changed, 3 deletions(-)
>=20
> This should also go through David Miller's networking tree's.  Adding
> netdev mailing list.
>=20
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

After looking at this further, I rescind my ACK.

NAK, this define is used in several places in ixgbe_main.c and the
driver will not compile with this patch.

>=20
> >=20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_type.h
> > index 204848d..c8d8040 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > @@ -32,9 +32,6 @@
> >  #include <linux/mdio.h>
> >  #include <linux/netdevice.h>
> > =20
> > -/* Vendor ID */
> > -#define IXGBE_INTEL_VENDOR_ID   0x8086
> > -
> >  /* Device IDs */
> >  #define IXGBE_DEV_ID_82598               0x10B6
> >  #define IXGBE_DEV_ID_82598_BX            0x1508
>=20
>=20


--=-WmKfEnkVjb2fYf4OVnMI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP/xRKAAoJEOVv75VaS+3OXD4P/2+CREWgOn/B6f8nhE5iPfpN
+GVG0mt2p5Fa+vRA8h+MaoviBEp7LQKYExC35iyqiuaguevdvkJWv9oZS3vhozhi
8GJ4SedxwTO+A4mcoWDoCPhUHYoIfcZXl+f3EmSnLD/u8T+l2oBfnI4fTAQA8+Sh
VhixDsQsEYl0KYqOlA17qCy1V5WTOCZCDA6y4pcXbM0z97DepUTpxAPBZUax1b8C
F3UKMulcUQz9foixt6puPejvJPvfuBJEX6UCW1kg/d3lEFT//9XTjLzUViPbT7pf
9y17COLPyMg6I2s2gkCpvMScs+uy9BfRV+IuRWO5JSJch1EIPiiHeZ+nDHCecotj
FmFx8OBUjS87C7dJxVLAsgr8HzO+2CgDY2xGRVXIBNMegRK8P1vctzxDsADJeWCV
n3yXTAVuQOLOXBBrEJAC8rsfUo2qevC+85LO424hf1rtWj6wikIuYp7vPTrrm8xU
zOOloSOKbklFeOhnjwxSXaQ3pKVU09YpnyAfvXntHeDJYCpqyq4EPKmNmjD7YTaL
u9oEIs+EJpO9AtgY6U6OPRSojTxwaeP5KTsL/WGAo7bDdxU9+ugVZnsJIiepvsq/
u7kZnaLfgJer4RNqIAMzY4eU+xj0ZFWRQ2aeTYyT+NnDuZTBCFNeC6JI836aguoB
TeN0fKqpSQex+MxVKXh1
=ZJ2X
-----END PGP SIGNATURE-----

--=-WmKfEnkVjb2fYf4OVnMI--
