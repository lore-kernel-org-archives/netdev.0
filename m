From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Tue, 04 Jan 2011 11:54:42 +0100
Message-ID: <4D22FC72.7040706@pengutronix.de>
References: <20101224091428.GA375@e-circ.dyndns.org>	<4D148788.3010808@pengutronix.de>	<20110103163835.GD320@e-circ.dyndns.org>
	<20110103.093327.104057155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5590313513036385914=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110103.093327.104057155.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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
--===============5590313513036385914==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAC4AF823FABD19FAB1D2CD1D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAC4AF823FABD19FAB1D2CD1D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/03/2011 06:33 PM, David Miller wrote:
> From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
> Date: Mon, 3 Jan 2011 17:38:35 +0100
>=20
>> On Fri, Dec 24, 2010 at 12:44:08PM +0100, Marc Kleine-Budde wrote:
>>>
>>>>> hmmm..all stuff behind dpram is __iomem, isn't it? I think it shoul=
d
>>>>> only be accessed with via the ioread/iowrite operators. Please chec=
k
>>>> I did an ioremap_nocache. Since it is unaligned, ioread/iowrite woul=
d render
>>>> a lot of statements.
>>>
>>> The thing is, ioremapped mem should not be accessed directly. Instead=

>>> ioread/iowrite should be used. The softing driver should work on non =
x86
>>> platforms, too.
>>>
>> I use __attribute__((packed)) structs to refer to the iomemory.
>> To read an unaligned uint16_t, is should then use 2 readb()'s ??
>>
>> I could of course turn that sequence into a macro ....
>=20
> Yes, this is what you'll need to do.

There's ioread() and get_unaligned(). Do we have a combination of this?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAC4AF823FABD19FAB1D2CD1D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0i/HIACgkQjTAFq1RaXHOKlQCfXE6dKf/EvCls4MUAtCLNV80a
vEQAnjVwBGA4KFeKKd/OVRsvuh16FTaD
=EdEO
-----END PGP SIGNATURE-----

--------------enigAC4AF823FABD19FAB1D2CD1D--

--===============5590313513036385914==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5590313513036385914==--
