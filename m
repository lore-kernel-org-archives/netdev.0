From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 18:00:37 +0100
Message-ID: <459FD5B5.2050706@web.de>
References: <45996CBA.8020307@web.de>	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>	 <20070102162201.GA28457@infradead.org>	 <200701052108.40185.IvDoorn@gmail.com> <1168102377.5207.59.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2BE79F2F881E95FC7DDDA3AB"
Cc: Ivo van Doorn <ivdoorn@gmail.com>, Jiri Benc <jbenc@suse.cz>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:59368 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXAFRAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:00:47 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1168102377.5207.59.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2BE79F2F881E95FC7DDDA3AB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Johannes Berg wrote:
> On Fri, 2007-01-05 at 21:08 +0100, Ivo van Doorn wrote:
>=20
>> This patch uses the __set_bit and __clear_but as suggested by Christop=
h.
>> It also removes the local argument since it was unused.
>=20
> NACK. This breaks spec compliance for drivers that use the TIM in their=

> beacon frames.

Bit ordering, I see. Then go for my original patch + comments why this
is open-coded in __bss_tim_set/clear + removed unused arguments from
those functions, OK?

Jan


--------------enig2BE79F2F881E95FC7DDDA3AB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFn9W1niDOoMHTA+kRAm0dAJ4lbsVCgvOccL7yd/6JI0+bVoAG8gCfUF28
HoEtaWGJPXDGpDeZR7dHNdc=
=zU0y
-----END PGP SIGNATURE-----

--------------enig2BE79F2F881E95FC7DDDA3AB--
