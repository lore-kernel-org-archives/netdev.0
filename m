From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Thu, 12 May 2011 00:39:55 +0200
Message-ID: <4DCB103B.30801@pengutronix.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
	<201105112331.47954.arnd@arndb.de>
	<201105112344.44171.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0910448559493982823=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201105112344.44171.arnd-r2nGTMty4D4@public.gmane.org>
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
--===============0910448559493982823==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8EC241D29D6BBC8CC02C61B6"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8EC241D29D6BBC8CC02C61B6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/11/2011 11:44 PM, Arnd Bergmann wrote:
> On Wednesday 11 May 2011, Arnd Bergmann wrote:
>> If that interpretation is right, I would seriously recommend rethinkin=
g
>> the design of the CAN firmware for pruss, so you can start doing somet=
hing
>> useful with the offload engine that fits into the Socket CAN API, or t=
hat
>> would be a useful extension to Socket CAN that is also implementable i=
n
>> the kernel for all other drivers in a meaningful way.
>=20
> I've looked some more into the CAN socket implementation, and I suppose=
 that
> the idea of the pruss driver was really to help do the work from the
> can_rcv_filter function in hardware.
>=20
> Doing this right would really mean supporting both a mode where any new=

> filter that gets added to socket can ends up being added to the hardwar=
e
> as long as it fits, similar to how we can add additional unicast mac
> addresses to an ethernet NIC. However, when the filters from all user
> sockets combined can not be represented in the hardware driver, the har=
dware
> needs to be put into a less efficient mode where all packets are return=
ed
> to the kernel and processed in software.

I'm not sure if reprogramming hardware filters on the fly works on evey
can core. The more conservative solution would be to configure the
filter list globally (+when the interface is down) via netlink.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig8EC241D29D6BBC8CC02C61B6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3LED8ACgkQjTAFq1RaXHNdxACeLwFT0xztVWoeMHIpY40qta9E
WWAAnRavlolwmhlGdIetboj9G/+BQzB3
=qo1G
-----END PGP SIGNATURE-----

--------------enig8EC241D29D6BBC8CC02C61B6--

--===============0910448559493982823==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0910448559493982823==--
