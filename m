From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 15:00:06 +0200
Message-ID: <4E3FDDD6.1020802@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
	<1312641270-6018-6-git-send-email-holt@sgi.com>
	<4E3FA066.3020301@grandegger.com> <20110808113136.GS4926@sgi.com>
	<4E3FD184.1070706@pengutronix.de> <20110808124842.GT4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4177580035502953718=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808124842.GT4926-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4177580035502953718==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig42B3E84E7681BE97C529AB81"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig42B3E84E7681BE97C529AB81
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 02:48 PM, Robin Holt wrote:
>>> OK.  Dug a bit more.  The p1010 built-in clocksource seems to be the
>>> periphereal clock frequency which is system bus frequency divided
>>> by 2.  The clock source can not be changed, but the clock divider can=

>>> by freezing the interface and setting the CTRL register.  This appear=
s

>> Which bit(s) in the CTRL register is/are this?

> PRESDIV bits 24-31.  Documented on the P1010 reference manual section 2=
1.3.3.2.

We have and use these bits on arm, too. These bits are calculated and
set by the driver[1]. These bits are touched in freescale's 2.6.35
version of the flexcan driver, too.

=46rom my point of view it makes no sense to specify this divider in the
OF-tree. We just need the frequency of the clock entering the flexcan
core. Which is, as you say, the system bus freq/2.

[1]
http://lxr.linux.no/linux+v3.0.1/drivers/net/can/flexcan.c#L597
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig42B3E84E7681BE97C529AB81
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/3eEACgkQjTAFq1RaXHO0XACeKjUzj2FbRGcDeFtpKi7Zr64u
HDMAniaUNZNKIXs27vaPu/lHEWpK1p3x
=y/yp
-----END PGP SIGNATURE-----

--------------enig42B3E84E7681BE97C529AB81--

--===============4177580035502953718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4177580035502953718==--
