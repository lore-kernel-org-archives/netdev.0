From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 00/12] can: c_can: Fix a series of serious bugs and improve
 the performance
Date: Tue, 01 Apr 2014 10:09:19 +0200
Message-ID: <533A742F.4090703@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="EWCB91vJrpcPbhIxtuuWrBWgXnbRwSOn9"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EWCB91vJrpcPbhIxtuuWrBWgXnbRwSOn9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/01/2014 12:35 AM, Thomas Gleixner wrote:
> Dear Maintainers,
>=20
> On Tue, 18 Mar 2014, Thomas Gleixner wrote:
>> The driver is full of serious bugs:
>>
>>     - Two HW init routines are not spec compliant.
>>
>>     - Completely defective message buffer handling in several ways
>>       That leads to interrupt storms and complete lockups.
>>
>>     - Complete lack of SMP awareness
>>
>> What's amazing is that people "optimize" and "fix" the driver over and=

>> over, but nobody bothered to understand the manual and repair the code=

>> for real.
>>
>> The series fixes _ALL_ bugs which I found so far, but I'm sure there
>> are more issues burried in that unreadable mess. I'm just not able to
>> trigger them.
>=20
> What's the state of this series?

I'll apply your patches today.

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--EWCB91vJrpcPbhIxtuuWrBWgXnbRwSOn9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlM6dC8ACgkQjTAFq1RaXHOFOACaAtXIoGSUNPBLjRMmEIjNdo81
lcgAn3Wy6+7nWuvi66RESejTkhVHbgZQ
=XWTr
-----END PGP SIGNATURE-----

--EWCB91vJrpcPbhIxtuuWrBWgXnbRwSOn9--
