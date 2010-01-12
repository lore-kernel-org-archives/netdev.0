From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per interface
Date: Tue, 12 Jan 2010 01:09:09 +0100
Message-ID: <4B4BBDA5.8010808@gmail.com>
References: <4B4630C0.6090206@gmail.com> <4B467A4D.9070708@gmail.com>	 <1263252108.29868.4774.camel@calx>	 <20100111.155912.68138954.davem@davemloft.net> <1263254625.29868.4777.camel@calx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8D877BCA6BA24570F9167579"
Cc: David Miller <davem@davemloft.net>, danborkmann@googlemail.com,
	linux-kernel@vger.kernel.org, jmoyer@redhat.com,
	netdev@vger.kernel.org, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:58905 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab0ALAJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 19:09:31 -0500
In-Reply-To: <1263254625.29868.4777.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8D877BCA6BA24570F9167579
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Matt Mackall wrote:
> On Mon, 2010-01-11 at 15:59 -0800, David Miller wrote:
>> From: Matt Mackall <mpm@selenic.com>
>> Date: Mon, 11 Jan 2010 17:21:48 -0600
>>
>>> Looks pretty good. Dave?
>>>
>>> Acked-by: Matt Mackall <mpm@selenic.com>
>> I don't like the loop for RX ARP processing.
>>
>> The packet contents aren't going to change, so doing basic
>> packet validation inside of the "for each RX client" loop
>> of arp_reply() doesn't make any sense.
>=20
> True. Dan, please help our poor compilers with some manual loop
> invariant motion.

Okay, true. I'll fix this by tomorrow and resend the patch.

Best regards,
Daniel


--------------enig8D877BCA6BA24570F9167579
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktLvaUACgkQ5AxJm1m3CC8DEACgmoly7e3ugTj87vcvytfdJPyP
1KsAniSKXoLfTOQTAIYBqaOaZNSNOvvX
=6nem
-----END PGP SIGNATURE-----

--------------enig8D877BCA6BA24570F9167579--
