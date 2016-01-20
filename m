From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V3 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 16:09:48 +0100
Message-ID: <569FA33C.5060805@pengutronix.de>
References: <569F944A.4090201@pengutronix.de>
 <201601201541.53246.marex@denx.de> <569F9DE2.10405@pengutronix.de>
 <201601201603.40080.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="J5HikbGocjGbKBHjwv7vioqgbpG7PBRXU"
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:36692 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933889AbcATPKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 10:10:01 -0500
In-Reply-To: <201601201603.40080.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--J5HikbGocjGbKBHjwv7vioqgbpG7PBRXU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 04:03 PM, Marek Vasut wrote:
>>
>> Doh! Right, let's try this:
>>>> -#define IFI_CANFD_INTERRUPT_ERROR_WARNING      BIT(1)
>>>> +#define IFI_CANFD_INTERRUPT_ERROR_WARNING      ((u32)BIT(1))
>>>
>>> I'd be happy to be proven wrong though.
>>
>> /me too
>=20
> I think that will do the trick too. Do you want a V4 patch or will you =
fix it?

I'll fix this.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--J5HikbGocjGbKBHjwv7vioqgbpG7PBRXU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn6M8AAoJEP5prqPJtc/HbtIH/iKjeclGbf98PDzVO7Cp1/14
fdtkzzmrQaBeyoT3MP1z17EGfwLA/j6ncfpsLPvAnAZcJMtwcnp4pprcemfO38rl
IbOz6QoQwKLZkxkcFFGaOvVlEvs3C0jh2xXoJ6oKzTPz2tCLERLltb75hwMZrcB2
/wFWmfv2D81SBMb22pSQy0fyioXawmGd7rSeK//Vu2yrArDQg7+jRBxbiD20du9o
BKWDN4fCQl7xlOzvXvRAKzbWL6Ul0YTjyheZ9oZJ5M3SFChpiUHYqb9xvVAfdwOa
cHqagsjVG1oB3/vIbYZLVbTeyHOJpKnrf3dLs7wbpmx1mXdCG5mVIpOFgFgo0iE=
=7nhO
-----END PGP SIGNATURE-----

--J5HikbGocjGbKBHjwv7vioqgbpG7PBRXU--
