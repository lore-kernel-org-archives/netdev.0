From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 2/4] [flexcan] Introduce a flexcan_clk set of functions.
Date: Fri, 05 Aug 2011 14:29:46 +0200
Message-ID: <4E3BE23A.5080706@pengutronix.de>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>	<1312509979-13226-3-git-send-email-holt@sgi.com>	<4E3BAB03.4040803@pengutronix.de>
	<20110805113638.GF4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6681007921801165588=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110805113638.GF4926-sJ/iWh9BUns@public.gmane.org>
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
--===============6681007921801165588==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig20BD37DA79E5AF53E245E8B9"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig20BD37DA79E5AF53E245E8B9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/05/2011 01:36 PM, Robin Holt wrote:
> I implemented the coding style changes below (Sorry I missed the two
> the first time).

np :)

> As for a better implementation, I guess I would need to understand what=

> is being attempted here.  I only marginally understand the flexcan
> hardware on the Freescale P1010 and certainly am clueless about arm
> implementations of flexcan.  I just skimmed over freescale's site

The arm side is working already :)
However we just support the busclock on ARM [1]. For the first shot
stick to that clock, too.

[1] (http://lxr.linux.no/linux+v3.0/drivers/net/can/flexcan.c#L857)

> and it looks like I would be looking at their i.MX25, i.MX28, i.MX35,
> and i.MX53 family of processors.  I will attempt to find some useful
> documentation of those and look at the kernel sources for what the clk_=
*
> functions are trying to accomplish.
>=20
> I _THINK_ I understand.  It looks like I could implement this as a powe=
rpc
> p1010 specific thing and get the same effect without impacting flexcan.=
c.
> I also think I understand that the i.MX25 family of processors do
> essentially the same thing the p1010 is doing for determining the
> clock rate.

It seems that arch/powerpc/platforms/512x/clock.c implements a clock
interface. I think the p1010 should implement something similar. (Note:
I'm not a ppc guy :)

I'm looking forward for new patches.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig20BD37DA79E5AF53E245E8B9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk474j0ACgkQjTAFq1RaXHObSQCfUP4BNDFP79pY64fYyH9rnro4
vgwAmwbsc7CwkQqvLj1Ttd4xTBKHEOAu
=84PX
-----END PGP SIGNATURE-----

--------------enig20BD37DA79E5AF53E245E8B9--

--===============6681007921801165588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6681007921801165588==--
