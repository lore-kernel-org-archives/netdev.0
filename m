From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v3 8/8] i2c: Add device tree support to i2c-pnx.c
Date: Wed, 18 Apr 2012 20:09:17 +0200
Message-ID: <20120418180917.GD2548@pengutronix.de>
References: <1333528480-17134-1-git-send-email-stigge@antcom.de>
 <1333528480-17134-9-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WChQLJJJfbwij+9x"
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org, jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
To: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333528480-17134-9-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--WChQLJJJfbwij+9x
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 04, 2012 at 10:34:40AM +0200, Roland Stigge wrote:
> This patch adds device tree support to the pnx-i2c driver by using platfo=
rm
> resources for memory region and irq and removing dependency on mach inclu=
des.
>=20
> The following platforms are affected:
>=20
> * PNX
> * LPC31xx (WIP)
> * LPC32xx
>=20
> The patch is based on a patch by Jon Smirl, working on lpc31xx integration
>=20
> Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
> Reviewed-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

I added devicetree-discuss to the (quite long) CC list. I am not sure
about all of the bindings.

>=20
> ---
>=20
>  Applies to v3.4-rc1
>=20
>  Documentation/devicetree/bindings/i2c/pnx.txt |   40 ++++++++++++++++
>  drivers/i2c/busses/i2c-pnx.c                  |   65 +++++++++++++++++++=
-------
>  include/linux/i2c-pnx.h                       |    1=20
>  3 files changed, 89 insertions(+), 17 deletions(-)
>=20
> --- /dev/null
> +++ linux-2.6/Documentation/devicetree/bindings/i2c/pnx.txt
> @@ -0,0 +1,40 @@
> +* NXP PNX I2C Controller
> +
> +Required properties:
> +
> + - reg: Offset and length of the register set for the device
> + - compatible: should be "nxp,pnx-i2c"
> + - interrupts: configure one interrupt line
> + - #address-cells: always 1 (for i2c addresses)
> + - #size-cells: always 0
> +
> +Optional properties:
> +
> + - interrupt-parent: the phandle for the interrupt controller that
> +   services interrupts for this device.

That one is not optional, or? You always need it but in most cases it
gets inherited as I understand.

> + - clock-frequency: desired I2C bus clock frequency in Hz, Default: 1000=
00 Hz
> + - pnx,timeout: I2C bus timeout in milliseconds, Default: 10 ms

To devicetree-folks: Can we argue this is a hardware property of the
bus? Then we could introduce a generic "timeout" property? I see, there
is already "fsl,timeout", and it won't make sense to have that per
vendor?

> + - slave-addr: Address used by the controller, Hardware default: 110

I'd prefer the hex value here, I2C addresses are mostly specified in
hex.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--WChQLJJJfbwij+9x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAk+PA00ACgkQD27XaX1/VRt/8QCgjlrbuHKQdptRbdHsIJm58tb8
GwUAnjN9z15pvmRNOqQFiJh9BRuaGGCm
=CaWN
-----END PGP SIGNATURE-----

--WChQLJJJfbwij+9x--
