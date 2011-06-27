From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] net/can: activate bit-timing
 calculation and netlink based drivers by default
Date: Mon, 27 Jun 2011 16:49:03 +0200
Message-ID: <4E08985F.2090300@pengutronix.de>
References: <1309160391-22486-1-git-send-email-mkl@pengutronix.de>
	<20110627135044.GF318@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7006492234954952297=="
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110627135044.GF318-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7006492234954952297==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDA6811319EEE1EF54A98C63A"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDA6811319EEE1EF54A98C63A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/27/2011 03:50 PM, Kurt Van Dijck wrote:
> Is this modification then also the right thing to do?

yes - there's no need for "default N' (or 'default n') as it's default.

> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 1d699e3..ac48574 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -4,7 +4,6 @@ menu "CAN Device Drivers"
>  config CAN_VCAN
>  	tristate "Virtual Local CAN Interface (vcan)"
>  	depends on CAN
> -	default N
>  	---help---
>  	  Similar to the network loopback devices, vcan offers a
>  	  virtual local CAN interface.
> @@ -15,7 +14,6 @@ config CAN_VCAN
>  config CAN_SLCAN
>  	tristate "Serial / USB serial CAN Adaptors (slcan)"
>  	depends on CAN
> -	default N
>  	---help---
>  	  CAN driver for several 'low cost' CAN interfaces that are attached
>  	  via serial lines or via USB-to-serial adapters using the LAWICEL
> @@ -124,7 +122,6 @@ source "drivers/net/can/softing/Kconfig"
>  config CAN_DEBUG_DEVICES
>  	bool "CAN devices debugging messages"
>  	depends on CAN
> -	default N
>  	---help---
>  	  Say Y here if you want the CAN device drivers to produce a bunch of=

>  	  debug messages to the system log.  Select this if you are having

If you make a patch from it...

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDA6811319EEE1EF54A98C63A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4ImGIACgkQjTAFq1RaXHOYnwCeKW+wXZFJFSy0QhuLqZoQlVXM
y+wAoIMg6CEJ9LSg93Ubcr5yxxGPCW9a
=RAkZ
-----END PGP SIGNATURE-----

--------------enigDA6811319EEE1EF54A98C63A--

--===============7006492234954952297==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============7006492234954952297==--
