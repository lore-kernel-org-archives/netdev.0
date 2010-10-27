From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver:
	Fix	buildwarnings
Date: Wed, 27 Oct 2010 13:58:39 +0200
Message-ID: <4CC813EF.4030408@pengutronix.de>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>	<20101026.105545.200376685.davem@davemloft.net><4CC71DA4.3020600@grandegger.com>	<4CC72360.1070608@pengutronix.de>
	<008201cb75c9$f27ff720$66f8800a@maildom.okisemi.com>
	<4CC813B9.3080506@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0677851867175729074=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CC813B9.3080506-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============0677851867175729074==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1D28B4BD9011CA4ABE93FA5D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1D28B4BD9011CA4ABE93FA5D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/27/2010 01:57 PM, Wolfgang Grandegger wrote:
> On 10/27/2010 01:27 PM, Tomoya MORINAGA wrote:
>> On Wednesday, October 27, 2010 3:52 AM :  Marc Kleine-Budde and Wolfga=
ng Grandegge wrote:
>>
>> The following is some inarticulate points I have for your questions.
>> Please give me more information.
>>
>>> Do I understand your code correctly? You have a big loop, but only do=

>>>  two different things at certain values of the loop? Smells fishy.
>> Uh, I can't understand your intention.
>> Please show in detail.
>> This processing does configuration for all message objects.
>=20
> Not all, but just a few of them. We believe it can be implemented more
> efficiently.

I misread the code...sorry - I'm just writing a longer answer.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1D28B4BD9011CA4ABE93FA5D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzIE/QACgkQjTAFq1RaXHM64wCeLi5aG/VvvhsC0kfOPgSOtBBI
gswAnRrGtfoJvQqemB06JlOpN44psMnk
=kSXp
-----END PGP SIGNATURE-----

--------------enig1D28B4BD9011CA4ABE93FA5D--

--===============0677851867175729074==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0677851867175729074==--
