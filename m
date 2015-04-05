From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: return non-zero from do_sset() when any of
 ETHTOOL_{G,S}* fails
Date: Sun, 05 Apr 2015 02:55:48 +0100
Message-ID: <1428198948.11260.133.camel@decadent.org.uk>
References: <1423236283-32446-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o4Hc57NEIWhAIRSObBaG"
Cc: netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58717 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751384AbbDEB4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 21:56:00 -0400
In-Reply-To: <1423236283-32446-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o4Hc57NEIWhAIRSObBaG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-02-06 at 16:24 +0100, Ivan Vecera wrote:
> Function do_sset returns unconditionally zero error code without regard
> to return value of ETHTOOL_{G,S}* ioctls.
[...]

This behaviour is stupid, but it's what ethtool has always done and what
some scripts will depend on now.  If you can think of a simple way for
scripts to opt-in to sensible exit codes, please submit that.

Also, negative exit codes aren't sensible; please just use 0 and 1.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-o4Hc57NEIWhAIRSObBaG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCWKee/yOyVhhEJAQr7JRAArW1M0ePDh+tbjccSPy1P0VWlD+hpfZIi
FvPybmSf+XLT9XAGUZino1hW5nx+wi/o6sQyfmBFzEiz1+6CBPMNkvilEZiUY23e
LpxZIG8UPImMbBnGQdHwmaREK7FrqpAT79PhrmNXu5zYik7LOsBxt1OlIzF8AzOf
Uanqaq/E9aEBoW/1H9TZnd3V6OCcLHfwbd6FKTEDgmFhsCBGaMIG8LKEfGe/+54V
d4jDvGa6Sp/GyEjFpfCz1k7zi4t02gd1YUMEo+jXO8to851L8Eq/o4hbyx5/2F0c
v8fv1kbsejTWF3NtkwzJ1bWjhz0r0ovOqA0vK0+8doc8wiVkQ6830YB4JJJXkElm
nevRjpKXzxB9cWNElGaqCA8pzp8d7nTgyF95bkMNPWraHBUEFxyGZ2dpG8i0enVI
fdZrAUtZETCv/gta0t4E2Hfz9326UzyQ10kA94g2a4+GhaTIY2KhThBr7YDbPqgT
oW0rNRu3gd4y763E8woUy/8eufmUwxQm1Kcs+yBtdsLo8IDPoWLN4beT5SZQOjk/
yOj0EFu4ptbooCzhm1qXFpy3vm5PEvVmlmz0HXRiDVlhtP6WPviT7rmj7TZ9aqO/
E4laRFOQT/n9dR5yb3kALfh0z+KrBTsrRu954FP3b/Ce0aWHD7HKuoIHVBmgZXVy
STBtw2xNJx4=
=FIch
-----END PGP SIGNATURE-----

--=-o4Hc57NEIWhAIRSObBaG--
