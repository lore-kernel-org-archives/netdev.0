From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: drivers/net: Kconfig & Makefile cleanup
Date: Tue, 22 Nov 2011 06:49:00 +0000
Message-ID: <1321944540.2839.220.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LAcYlV4XZjiKayKzLYsG"
Cc: netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54181 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754882Ab1KVGtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 01:49:08 -0500
Received: from [2001:470:1f08:1539:21c:bfff:fe03:f805] (helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <ben@decadent.org.uk>)
	id 1RSkAF-0003RV-Le
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 06:49:07 +0000
Received: from ben by deadeye with local (Exim 4.77)
	(envelope-from <ben@decadent.org.uk>)
	id 1RSkA9-0001DR-Bd
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 06:49:01 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LAcYlV4XZjiKayKzLYsG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You wrote that (some time ago now):
> As a side cleanup, found that the arcnet, token ring, and PHY
> Kconfig options were a tri-state option and should have been
> a bool option.

How did you decide that?  This seems to be correct for TR, but ARCNET
and PHYLIB each select some support code that can be built as a module
(and which has been, in Debian).

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.


--=-LAcYlV4XZjiKayKzLYsG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATstF3Oe/yOyVhhEJAQolfhAAt/JeiW5TFFnUwcDbZ06eVk0CPbSOqpmv
DlEmLjHkV9hNg7i1UyKdzWbTBJfRb9BULH4PX7wfpIPZgTUgf43Yu/JG9t4KJoe/
BIEMyO0shl9lv6HgGaU2KrfDve1jEa/NpVVFOmvWvMZFFjTCTd5MX5NMMkL10cio
f4YGhB/KXHQbaPVpPl69eOst7PBi3uPetwnIw9l45jnAW9AtK5YttEQlngqOG4VB
fqp03oQ6RNuue7YE4v8zlYuo80oSujOSGj6tdT4HU4TOezA8AaHGCSxA/fkFyH4B
w/oQFnMA7GzE7w0xtP2vX1jz9pOx6kNzqFxr++mCB9xl/h1cQRKqdKrZiyQ9M2hU
4fWOXpbbRs9YuvHC5qpmYzw4hrIbmdxVg4gwzo/XV8/YzFnqluZ0rtb10znilcsL
JjHkCjcw3etoA+3McBhDQqDmScOzR1pcUE7nMbCsj4pjZlTqiUbJfsXDAvdN4vzn
60+Uxm7NXPgBYVQwCfi1B5IiWg/nH3Yru+rsmTiUjFug3jfAUzv+7OvQ/pxfJ/BR
jt8t0PMck7OdIlhaCwL6EnUU3GShzXmLelJk+5DsaE+s5x4IRhaZzel7OKoQMBqO
+LSBdH7g2YcPG8ocbuUo4YdxthY+B9UEAuFhBIu6pPokYxJBvuMorfQoVWXtgm/L
slRk0IUg5dg=
=uk8Y
-----END PGP SIGNATURE-----

--=-LAcYlV4XZjiKayKzLYsG--
