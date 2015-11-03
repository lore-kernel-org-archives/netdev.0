From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 12:36:24 +0100
Message-ID: <56389C38.4080508@pengutronix.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
 <201511021916.18117.marex@denx.de>
 <666821254.20151102231521@cogentembedded.com>
 <201511022125.47892.marex@denx.de>
 <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TEiJvnhocwwrjQISqRj9EmjRoSHN5pVit"
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>,
	Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56039 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbbKCLgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 06:36:41 -0500
In-Reply-To: <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TEiJvnhocwwrjQISqRj9EmjRoSHN5pVit
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2015 11:36 AM, Aleksander Morgado wrote:
> On Mon, Nov 2, 2015 at 9:25 PM, Marek Vasut <marex@denx.de> wrote:
>>>> I was thinking about this and I mostly agree with you. Obviously, co=
pying
>>>> the code this way was dumb. On the other hand, ARINC and CAN are two=

>>>> different sort of busses, so I'd propose something slightly differen=
t
>>>> here to avoid confusion and prevent the future extensions (or protoc=
ols)
>>>> from adding unrelated cruft into the CAN stack.

> I'd keep them separate not because ARINC may add unrelated cruft into
> the CAN stack, but because ARINC is much simpler than CAN already...

What about maintainability? Why take care of two almost identical
subsystems? With making one stack "simpler" you increase, from my point
of view, the costs of maintaining even more. If you fix problems in one
stack you have to adopt the other, too.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--TEiJvnhocwwrjQISqRj9EmjRoSHN5pVit
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWOJw4AAoJEP5prqPJtc/Hx8YH/ifUbMmTCuQNRcxC0m3qUMKd
JNlbP37Y0vSgXA8BjZcPFrwnd0nbcKZZonP8rOHARopqTg/sXJf/yCCW7zC5vY29
LG5jTZR9C9shRpaI/59oavABanzP57jffILUTlJ5G/21gWqgCOGvcnLRfgAlECp3
T8DfNvCUrbvYsVhZPeqhN3iHaERrGKA/VHbAzswb0BhseFYpXJUT+3bgGESJx+NX
qeu//zfeJHyvV9ZRzhlKeQv1QKx3X3pItcUOVyapXaTrToCsqA3jj2fQ3CYbu17I
PZGpfjYmU39iRZ3N3JHJdhhOtBFEiiWa7QAzyn9XrP/DibvJNNscZEbMWNe0KLU=
=/rmB
-----END PGP SIGNATURE-----

--TEiJvnhocwwrjQISqRj9EmjRoSHN5pVit--
