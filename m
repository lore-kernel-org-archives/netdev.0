From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu, 03 Nov 2011 16:03:23 +0100
Message-ID: <4EB2AD3B.6030207@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <20111103100333.GD317@e-circ.dyndns.org> <4EB27026.90301@pengutronix.de> <4EB2A4DA.6040800@hartkopp.net> <20111103143752.GB7718@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig79094C66FF7D3F8E36ABA301"
To: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56995 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495Ab1KCPD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 11:03:28 -0400
In-Reply-To: <20111103143752.GB7718@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig79094C66FF7D3F8E36ABA301
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2011 03:37 PM, Kurt Van Dijck wrote:
> On Thu, Nov 03, 2011 at 03:27:38PM +0100, Oliver Hartkopp wrote:

>>>> Next step would be to do the statistics inside can_get_echo_skb(), b=
ut that's
>>>> affecting all drivers using it ...
>>>> Kurt
>>>
>>> Interesting idea
>>
>>
>> Yes, but then the name of the function is not appropriate anymore.
>>
>> The return value for can_get_echo_skb() gives a silent improvement tha=
t can be
>> adopted by CAN drivers by the time. But hiding more functionality insi=
de this
>> function may lead to misunderstandings.
> That's what I described with the obscure phrase "..." :-)
>=20
> Marc's proposed patch is indeed easier to digest at the time.

+1, I'll repost my fixed branch. Let's first integrate that one.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig79094C66FF7D3F8E36ABA301
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6yrT4ACgkQjTAFq1RaXHO1IQCdHWvuRhO6Gmb+CT0Sc2QEkaIz
6cEAnjaJQGeZm99kQoV0GKNJ1EsTZL0U
=WJkx
-----END PGP SIGNATURE-----

--------------enig79094C66FF7D3F8E36ABA301--
