From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: flexcan: use be32_to_cpup to handle the value of
 dt entry
Date: Wed, 27 Jun 2012 13:34:25 +0200
Message-ID: <4FEAEFC1.4060104@pengutronix.de>
References: <1340789236-28266-1-git-send-email-mkl@pengutronix.de> <1340789236-28266-2-git-send-email-mkl@pengutronix.de> <CAAQ0ZWT3ovG7eKZZuoSZkx4FGd+W9XvnTk8R1yuD02u4wqGNHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC55E22088C084ADF27C3CFA6"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Hui Wang <jason77.wang@gmail.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAAQ0ZWT3ovG7eKZZuoSZkx4FGd+W9XvnTk8R1yuD02u4wqGNHQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC55E22088C084ADF27C3CFA6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/27/2012 01:26 PM, Shawn Guo wrote:
> On 27 June 2012 17:27, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>> From: Hui Wang <jason77.wang@gmail.com>
>>
>> The freescale arm i.MX series platform can support this driver, and
>> usually the arm cpu works in the little endian mode by default, while
>> device tree entry value is stored in big endian format, we should use
>> be32_to_cpup() to handle them, after modification, it can work well
>> both on the le cpu and be cpu.
>>
> I'm wondering if you want to just use of_property_read_u32() to make
> it a little bit easier.

Even better. Hui can you send a updated patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC55E22088C084ADF27C3CFA6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/q78QACgkQjTAFq1RaXHOc0wCfVbEi3KS4ohqHZCFvAyZCygQu
IUIAniOSH3w96slu5pFbTt52QaX49LwZ
=32Yu
-----END PGP SIGNATURE-----

--------------enigC55E22088C084ADF27C3CFA6--
