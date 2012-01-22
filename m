From: Richard Weinberger <richard@nod.at>
Subject: ipt_LOG: No space after prefix
Date: Sun, 22 Jan 2012 13:54:49 +0100
Message-ID: <4F1C0719.1010609@nod.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC32B9631C6618A973A6C748B"
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:47835 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab2AVMy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 07:54:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC32B9631C6618A973A6C748B
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi!

Is there no space after prefix for specific reason?
ipt_log_packet() is using this format string:
"<%d>%sIN=3D%s OUT=3D%s "

Using a prefix leads to a broken log entry like this one (prefix is "foo"=
):
"fooIN=3Deth0 OUT=3D ..."
I'm sure this breaks log analyzers.
I've never noticed this because I'm using prefix very seldom.

Thanks,
//richard


--------------enigC32B9631C6618A973A6C748B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPHAceAAoJEN9758yqZn9euSEH/05iT13o46yEJG+yrz4ug2je
qlBNhbi39h7bAoemdpq1zd7tOG0bZUdIlt2Rd0KzdlauFgKVwHRV8jE+NLaoDLGT
hgKia+U/YV4lYrl/06ZgKlJ7gU1EF6zBKrAGqICv6Z6bJiSAWjp6054Wp8vlQIN2
FW6wL1M2crPVGY+dRWJYYlI7e2FhaYqKxwc69WhT0rAGxQuAWA5PytxNr8QK7mZX
sd21WGoxqzX17k3j9nLl/XfGdHe0esMLq/hYXx77A7KshXgNtDcfDT8ifl9EQa0d
aIxjjrK9A0gxvfFEmzGPN7EWtPLYv7eKcw1wha8GYr8fv+2+S+jBDn+118EyrPk=
=4Nb+
-----END PGP SIGNATURE-----

--------------enigC32B9631C6618A973A6C748B--
