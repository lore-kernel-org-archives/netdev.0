From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
Date: Mon, 15 May 2017 15:50:27 +0200
Message-ID: <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
 <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="qHkDi8659UvibxeWKjBOsNhLJ0mEsG425"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qHkDi8659UvibxeWKjBOsNhLJ0mEsG425
Content-Type: multipart/mixed; boundary="sPgoJ1gKPi0JeA7DwpLWN9rh0CL3woRJR";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Quentin Schulz <quentin.schulz@free-electrons.com>, wg@grandegger.com,
 mario.huettel@gmx.net, socketcan@hartkopp.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 thomas.petazzoni@free-electrons.com
Message-ID: <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
 <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
In-Reply-To: <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>

--sPgoJ1gKPi0JeA7DwpLWN9rh0CL3woRJR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/12/2017 08:37 AM, Quentin Schulz wrote:
> Hi all,
>=20
> On 05/05/2017 15:50, Quentin Schulz wrote:
>> To avoid possible ECC/parity checksum errors when reading an
>> uninitialized buffer, the entire Message RAM is initialized when probi=
ng
>> the driver. This initialization is done in the same function reading t=
he
>> Device Tree properties.
>>
>> This patch moves the RAM initialization to a separate function so it c=
an
>> be called separately from device initialization from Device Tree.
>>
>> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
>=20
> It's been a week since I sent this patch series. Any comments?

Looks good, added to linux-can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--sPgoJ1gKPi0JeA7DwpLWN9rh0CL3woRJR--

--qHkDi8659UvibxeWKjBOsNhLJ0mEsG425
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkZsiMACgkQHv7KIOw4
HPZf1ggAjnge4K+X6UcssAIWHQUEWHpHH6zZOp7bhfD8Wm+vf2+71YdIotHjShHg
G5jU3yK2FodBlrN1dbjkfuFAivN7ndqOQ8zvsefq4bbwCFhGvpt+ry5G2896hsIn
gOlA1tNK3uOY01VatnmPR+xJuzBwTz5oywYslVD4sTaVTF+Gz3odUwTiWnxg6+hQ
hC2KM9AgUMW2K3JiL4KhFjVum8A5jE76NLDG/3vyRgeynTwEBP0ZU870P01Cottq
S8qGXWWK92lhhWY5q+uviLP++8zqgnIAmJe71RHbOe4129L8ou3H6UPb/l0S6iu2
mU3HlDnTn21tfOj+7zQmzd6OOjWDRg==
=Krab
-----END PGP SIGNATURE-----

--qHkDi8659UvibxeWKjBOsNhLJ0mEsG425--
