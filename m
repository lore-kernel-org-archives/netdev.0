From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Thu, 12 May 2011 15:04:50 +0200
Message-ID: <4DCBDAF2.7040101@pengutronix.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<201105112344.44171.arnd@arndb.de>
	<4DCB88A4.2010901@grandegger.com>
	<201105121454.47781.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4651398350112798588=="
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org,
	davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201105121454.47781.arnd-r2nGTMty4D4@public.gmane.org>
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
--===============4651398350112798588==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCC74D13D42DE58C1FAC67592"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCC74D13D42DE58C1FAC67592
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/12/2011 02:54 PM, Arnd Bergmann wrote:
> On Thursday 12 May 2011, Wolfgang Grandegger wrote:
>> Well, that seems sophisticated resulting in a complex implementation
>> (may code line) also because hardware filters are very hardware
>> dependent. Usually just one global filter can be defined. I think that=
's
>> overkill. A simple interface using:
>>
>>   ip link set can0 type can filter <id>:<mask> [<id>:<mask> ...]
>>
>> would just be fine.
>=20
> Ok, fair enough. Still I would suggest you first come up with
> a reasonable user interface (the one you posted may be just right,
> I don't know), and then let someone do the implementation in the
> pruss firmware that is the best match for the user interface, rather
> than the other way around.

I suggested some time ago to implement the more-or-less standard
<id>:<mask> filter instead of just a single <id> (per filter entry). The
cost is probably quite low, it's just a single AND operation per filter
entry more expensive.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCC74D13D42DE58C1FAC67592
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3L2vIACgkQjTAFq1RaXHMrMQCfZRW8hn78Ku7PfDt63fmtOqlF
OjUAniY/vJwIb7SjKLLFF63Y1ZKqS3H1
=xc0D
-----END PGP SIGNATURE-----

--------------enigCC74D13D42DE58C1FAC67592--

--===============4651398350112798588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4651398350112798588==--
