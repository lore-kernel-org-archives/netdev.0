From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [can-next PATCH 1/1] net: can: c_can_platform: Use devm_ioremap
 instead of devm_ioremap_resource.
Date: Fri, 25 Jul 2014 15:06:03 +0200
Message-ID: <53D2563B.1090703@pengutronix.de>
References: <1406269181-4092-1-git-send-email-mugunthanvnm@ti.com> <4a97162dedd6ab064e83c52757f2ce42@mail.zeus03.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="duembwfNjUBjNsAK8or8Qhho4rhcAMHTq"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Pavel Machek <pavel@denx.de>, Thor Thayer <tthayer@altera.com>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Chen Gang <gang.chen@asianux.com>,
	George Cherian <george.cherian@ti.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wolfram Sang <wsa@sang-engineering.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4a97162dedd6ab064e83c52757f2ce42@mail.zeus03.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--duembwfNjUBjNsAK8or8Qhho4rhcAMHTq
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/25/2014 12:49 PM, Wolfram Sang wrote:
> Am 25-07-2014 08:19, schrieb Mugunthan V N:
>> From: George Cherian <george.cherian@ti.com>
>>
>> The raminit register is shared register for both can0 and can1.
>> Using devm_ioremap_resource fails the mapping for can1 interface
>> leading to a non functional can interface.
>>
>> Signed-off-by: George Cherian <george.cherian@ti.com>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>=20
> The patch is a hack, or? It simply works because we drop all sanity
> checking on the resource.

Well, thinking about it, yes, a bit.

> I am on holiday and can't really check, yet I believe the AM335x has
> devicetree support for accessing single bits in SYSCONF. This is what
> needs to be applied here, too, AFAICT.

I cannot find any generic driver for the sysconf, USB and Ethernet have
an extra driver for their shared register space. I think the d_can can
access the raminit register via a syscon driver.

Enjoy your holiday :)
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--duembwfNjUBjNsAK8or8Qhho4rhcAMHTq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPSVjsACgkQjTAFq1RaXHMPMACfUlhII5nD4DcN1u5YEoXtVeUZ
hP8Ani5sxhhe6a6WfzL48KqolRBU1Bt+
=sQbT
-----END PGP SIGNATURE-----

--duembwfNjUBjNsAK8or8Qhho4rhcAMHTq--
