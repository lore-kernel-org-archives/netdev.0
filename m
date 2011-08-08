From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 14:07:32 +0200
Message-ID: <4E3FD184.1070706@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
	<1312641270-6018-6-git-send-email-holt@sgi.com>
	<4E3FA066.3020301@grandegger.com> <20110808113136.GS4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2030089787590923184=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808113136.GS4926-sJ/iWh9BUns@public.gmane.org>
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
--===============2030089787590923184==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig41B4B46911F85EF5B70EFB51"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig41B4B46911F85EF5B70EFB51
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 01:31 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 10:37:58AM +0200, Wolfgang Grandegger wrote:
>> On 08/06/2011 04:34 PM, Robin Holt wrote:
>>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>>> to work.  This patch provides the minimum functionality.
>>
>> This needs some more general thoughts... apart from the question where=

>> the code should go.
>>
>> Like for the MSCAN on the MPC5200, the user should be *able* to select=

>> an appropriate clock source and divider via DTS node properties.
>> Currently it seems, that the DTS properties must match some
>> pre-configured values, most likely set by the boot loader. Please
>> correct me if I'm wrong. For me this is generic and should go into the=

>> Flexcan driver. From there, a platform specific function, e.g.
>> flexcan_set_clock() might be called.
>=20
> OK.  Dug a bit more.  The p1010 built-in clocksource seems to be the
> periphereal clock frequency which is system bus frequency divided
> by 2.  The clock source can not be changed, but the clock divider can
> by freezing the interface and setting the CTRL register.  This appears

Which bit(s) in the CTRL register is/are this?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig41B4B46911F85EF5B70EFB51
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/0YcACgkQjTAFq1RaXHOucQCfbpjrSHLbQWHBnbkUqDDMZ5ko
YQsAnie4/LNKAeroLiIoyoIn8EU1fIDa
=hS27
-----END PGP SIGNATURE-----

--------------enig41B4B46911F85EF5B70EFB51--

--===============2030089787590923184==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2030089787590923184==--
