From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: Question for canutils
Date: Wed, 27 Apr 2011 15:50:38 +0200
Message-ID: <4DB81F2E.4050802@pengutronix.de>
References: <02D6556ECE7A41859777EB7300D12394@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3745882904788517768=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	toshiharu-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	'Wolfgang Grandegger' <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <02D6556ECE7A41859777EB7300D12394-c0cKtqp5df7I9507bXv2FdBPR1lH4CV8@public.gmane.org>
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
--===============3745882904788517768==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2B978E32A41305D15BB0F9E9"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2B978E32A41305D15BB0F9E9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/27/2011 10:36 AM, Tomoya MORINAGA wrote:
> I have 2 questions for canutils.
>=20
> 1) Build issue
> I downloaded the latest canutils and libsocketcan.
>    - canutils-4.0.6
>    - libsocketcan-0.0.8
>=20
> Firstly, I installed libsocketcan-0.0.8

Into which location?

Please send me the output of:

ls -l /usr/local/lib
ls -l /usr/local/lib/pkgconfig

> Secondly, I tried to install canutils-4.0.6.
> But it failed like below.
>=20
> [root@localhost canutils-4.0.6]# ./configure
> ...snip...
> checking whether lstat correctly handles trailing slash... yes
> checking whether stat accepts an empty string... no
> checking for socket... yes
> checking for strchr... yes
> checking for strtoul... yes
> checking for pkg-config... /usr/bin/pkg-config
> checking pkg-config is at least version 0.9.0... yes
> checking for libsocketcan... no
> configure: error: *** libsocketcan version above 0.0.8 not found on you=
r system
> [root@localhost canutils-4.0.6]#=20
>=20
> Do you have any information about the fail?

> BTW, Using canutils-3.0.2, I could confirm build becomes success.

3.x doesn't work with the mainline configuration interface.

> 2) How to use
> Executing candump like following, I see the following message.(Of cours=
e, pch_can have already installed)
> [root@localhost morinaga]# candump can0
> interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
> read: Network is down
> [root@localhost morinaga]#
>=20
> Would you tell me how to active can0 interface.

First build the canutils, then configure the bitrate, e.g. 250 kbit/s:
    $ canconfig can0 bitrate 250000
    $ ifconfig can0 up

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2B978E32A41305D15BB0F9E9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk24HzIACgkQjTAFq1RaXHNjrgCdHOdfKWsLdbJtdm7nmFcOiQiq
5MYAoIdidwYj1JBB44NmLTYjUtCfs9Yv
=2jry
-----END PGP SIGNATURE-----

--------------enig2B978E32A41305D15BB0F9E9--

--===============3745882904788517768==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3745882904788517768==--
