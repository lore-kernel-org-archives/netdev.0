From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM
 dependency
Date: Sat, 21 Dec 2013 22:06:15 +0100
Message-ID: <52B602C7.4080307@pengutronix.de>
References: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com> <52B4B3E7.8050601@cogentembedded.com> <20131220213341.GA452@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="kfdvRu19csibNEhucvSt32gm5IXc9Glh8"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20131220213341.GA452@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kfdvRu19csibNEhucvSt32gm5IXc9Glh8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/20/2013 10:33 PM, Ezequiel Garcia wrote:
> On Sat, Dec 21, 2013 at 12:17:27AM +0300, Sergei Shtylyov wrote:
>> On 12/20/2013 11:14 PM, Ezequiel Garcia wrote:
>>
>>> OMAP's ti_hecc driver is used to support the CAN controller on many o=
map2plus
>>> SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to mak=
e this
>>> depend on OMAP3 only. Take an extra step, to get wider build coverage=
, and make
>>> the driver depend on ARM.
>>
>>     To have a real wide coverage, it's probably worth adding '|| COMIP=
LE_TEXT'=20
>> to 'depends on ARCH_OMAP2PLUS'?

> Yup, and that was my exact proposal on my reply to v1 (which I forgot t=
o detail
> in v2). I'd say it's Marc's call.

Convinced, I've added the v1 of this patch to can-next together with a
|| COMIPLE_TEXT.

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kfdvRu19csibNEhucvSt32gm5IXc9Glh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlK2AssACgkQjTAFq1RaXHMIAACfe5rZtxGeewg1TvhdNVj6mRe2
aRIAnRXEqBukZ2edmIvYyPJ6ktcmoJ4H
=uAUx
-----END PGP SIGNATURE-----

--kfdvRu19csibNEhucvSt32gm5IXc9Glh8--
