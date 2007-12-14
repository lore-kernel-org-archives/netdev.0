From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 13:54:57 +0100
Message-ID: <1197636897.16079.53.camel@johannes.berg>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
	 <E1J35d6-00041l-00@gondolin.me.apana.org.au>
	 <20071214002209.ac748206.akpm@linux-foundation.org>
	 <1197635860.16079.51.camel@johannes.berg>
	 <20071214124647.GB17898@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4ELQ0W70Bejq2BJ2vXXN"
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57995 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765186AbXLNMza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 07:55:30 -0500
In-Reply-To: <20071214124647.GB17898@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4ELQ0W70Bejq2BJ2vXXN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > I agree with this. IIRC I removed some ASSERT_RTNL()s in the wireless
> > code (or maybe it was only during testing patches) where we had a
> > function that required only the rtnl to be held but in certain contexts
> > was called from within an RCU section.
>=20
> Please point me to the actual code so I can see if this is legit
> or not.

I don't think I have that case any more since now my interface list is
either protected by RCU or the rtnl.

johannes

--=-4ELQ0W70Bejq2BJ2vXXN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2J9IKVg1VMiehFYAQJnHg/9Fa3G+pjeT7AA/T12+yVAyh72HTDCrUVe
BmvmAtuq7maURYh8kAmTRwd1OWcMTjRSSGczwzGCNgVL+SghiIZ/KKMHJSzYyqvo
/y1nikqQB/QXtg7/YmZ6yhe4Dl560E9HGk9QWWV+phWMjDUoNy5F1/JHkMqrkVd3
u6bBOINXcYFizpnaJDDa2AJvPA7Rh5in0OsK6bUe1/8T4Kjnv1hEo/Nc06a925zb
D0HhGFBDRro7yKRu3rJyN+b6AyUYHoVk1CT6XD+fth9/6p7dmmwGiXECwl2/ENut
977nwitL0FJiSbbW6k3JOUIH7VhbFkhukWJSoZ6sYUdWedsLttV/69q4y80iaIqJ
mJpPQ8S+QqHYCTES9ClQLhWsNiDr1mAJDGclATx2lzpjZLJ1UHGXFLTTCS9iokUX
dUlBJDASEMNYIqtIaFfhaOtJ212s8pZqb9SPnBIrtsG4oDvmK3DxFEHzHbLvtJ3e
vZLDudTjsCe//MqcnvHRipxflKf8YQmDT6ySQJYJKbN8GjUfBY97qF50qoLwcEEW
dAn4h5cPGJDVhJIKxrVYk2ZMVZXMSoKeLViV++TT7ehmIoO1M2KcL5QTKB5MkSRr
Qu00F+WrlutL+nnwh5X1427X9ZAOIoNM/VTr5oL+CRGX5Z3yn12zBfg78phS1ny1
XJIF8t75P7c=
=eHiE
-----END PGP SIGNATURE-----

--=-4ELQ0W70Bejq2BJ2vXXN--

