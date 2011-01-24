From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2 1/3] can: at91_can: clean up usage of	AT91_MB_RX_FIRST
	and AT91_MB_RX_NUM
Date: Mon, 24 Jan 2011 13:44:46 +0100
Message-ID: <4D3D743E.1030201@pengutronix.de>
References: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>	<1294752085-30151-2-git-send-email-mkl@pengutronix.de>	<4D349D8C.3010403@pengutronix.de>
	<20110121.165409.200115988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4524288515467409558=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110121.165409.200115988.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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
--===============4524288515467409558==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA69CC756316A117652BB8F90"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA69CC756316A117652BB8F90
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/22/2011 01:54 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Date: Mon, 17 Jan 2011 20:50:36 +0100
>=20
>> On 01/11/2011 02:21 PM, Marc Kleine-Budde wrote:
>>> This patch cleans up the usage of two macros which specify the mailbo=
x
>>> usage. AT91_MB_RX_FIRST and AT91_MB_RX_NUM define the first and the
>>> number of RX mailboxes. The current driver uses these variables in an=

>>> unclean way; assuming that AT91_MB_RX_FIRST is 0;
>>>
>>> This patch cleans up the usage of these macros, no longer assuming
>>> AT91_MB_RX_FIRST =3D=3D 0.
>>>
>>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>
>> Any comments on this?
>=20
> I would also seriously like to see these changes get some feedback,
> they've been rotting in patchwork for more than a week.

I've just talked to our customer (the one who noticed the problem in the
first place). They have the patched driver running over the weekend
without problems.

I'm going to resend the series the the Acks.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA69CC756316A117652BB8F90
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk09dEIACgkQjTAFq1RaXHO+wwCfTLQAQWsqTR6WKXn0T1fe3PG7
wlwAmgKrYD89660DgrlactGDcjoBQ6Yl
=AHs6
-----END PGP SIGNATURE-----

--------------enigA69CC756316A117652BB8F90--

--===============4524288515467409558==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4524288515467409558==--
