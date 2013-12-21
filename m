From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM
 dependency
Date: Sat, 21 Dec 2013 22:32:01 +0100
Message-ID: <52B608D1.2030105@pengutronix.de>
References: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com> <52B4B3E7.8050601@cogentembedded.com> <20131220213341.GA452@localhost> <52B602C7.4080307@pengutronix.de> <52B6134C.5080301@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4XAdwbcWbutOvKjQrFD7RTacio23CCDln"
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52B6134C.5080301@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4XAdwbcWbutOvKjQrFD7RTacio23CCDln
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/21/2013 11:16 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 12/22/2013 12:06 AM, Marc Kleine-Budde wrote:
>=20
>>>>> OMAP's ti_hecc driver is used to support the CAN controller on many=

>>>>> omap2plus
>>>>> SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to
>>>>> make this
>>>>> depend on OMAP3 only. Take an extra step, to get wider build
>>>>> coverage, and make
>>>>> the driver depend on ARM.
>=20
>>>>      To have a real wide coverage, it's probably worth adding '||
>>>> COMIPLE_TEXT'
>>>> to 'depends on ARCH_OMAP2PLUS'?
>=20
>>> Yup, and that was my exact proposal on my reply to v1 (which I forgot=

>>> to detail
>>> in v2). I'd say it's Marc's call.
>=20
>> Convinced, I've added the v1 of this patch to can-next together with a=

>> || COMIPLE_TEXT.
>=20
>    Sorry, I meant COMPILE_TEST, of course. :-<

lol, I copy/pasted the || COMIPLE_TEXT from you, but in the patch I
added the correct COMPILE_TEST:

-       depends on ARCH_OMAP3
+       depends on ARCH_OMAP2PLUS || COMPILE_TEST

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4XAdwbcWbutOvKjQrFD7RTacio23CCDln
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlK2CNYACgkQjTAFq1RaXHNC6ACdH51/dhWhPgMzdvYjTXKQwAZ3
PvAAn1iMGZDHPva9uw79WM3EyAlTG1na
=rCHK
-----END PGP SIGNATURE-----

--4XAdwbcWbutOvKjQrFD7RTacio23CCDln--
