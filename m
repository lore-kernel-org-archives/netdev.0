From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Mon, 23 May 2011 10:23:15 +0200
Message-ID: <4DDA1973.4090309@pengutronix.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<4DCB88A4.2010901@grandegger.com> <4DCBF1B6.6000104@hartkopp.net>
	<201105221230.56243.arnd@arndb.de> <4DD9FCFC.10803@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4242707717062897747=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DD9FCFC.10803-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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
--===============4242707717062897747==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC295372533A9F99782DE402D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC295372533A9F99782DE402D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/23/2011 08:21 AM, Oliver Hartkopp wrote:

[...]

> In 'real world' CAN setups you'll never see 21.000 CAN frames per secon=
d (and
> therefore 21.000 irqs/s) - you are usually designing CAN network traffi=
c with
> less than 60% busload. So interrupt rates somewhere below 1000 irqs/s c=
an be
> assumed.
>=20
> From what i've seen so far a 3-4 messages rx FIFO and NAPI support just=
 make it.
>=20
> @Marc/Wolfgang: Would this be also your recommendation for a CAN contro=
ller
> design that supports SocketCAN in the best way?

If you have a rx FIFO NAPI is the way to go. For a single mailbox it
adds overhead, if you can read the CAN frame in the interrupt handler.
The error messages should probably generated from NAPI, too. Especially
the I'm-the-only-CAN-node-on-the-net-and-get-no-ACK error message.

However IIRC David said that every new driver should implement NAPI.

> As the Linux network stack supports hardware timestamps too, this could=
 be an
> additional (optional!) feature.

regards, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC295372533A9F99782DE402D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3aGXYACgkQjTAFq1RaXHOi6ACfQ4kY0ukWKfqwYANq0x5mV3gD
lt8AoJjkRhJ0UWdPQ/dpzOA6WC4zJk6w
=v0Gq
-----END PGP SIGNATURE-----

--------------enigC295372533A9F99782DE402D--

--===============4242707717062897747==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4242707717062897747==--
