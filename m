From: Johannes Berg <johannes@sipsolutions.net>
Subject: sparse vs. skbuff.h
Date: Mon, 16 Nov 2009 20:21:11 +0100
Message-ID: <1258399271.32159.39.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-O+qeE3SDtWj/COxRAjbV"
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53763 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbZKPTVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 14:21:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-O+qeE3SDtWj/COxRAjbV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

commit 14d18a81b5171d4433e41129619c75748b4f4d26
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Oct 29 00:10:37 2009 +0000

    net: fix kmemcheck annotations


broke sparse endian checks on everything that includes skbuff.h because
the first and only (because it's an error) thing sparse now reports is
this:

include/linux/skbuff.h:357:41: error: invalid bitfield specifier for type r=
estricted __be16.

johannes

--=-O+qeE3SDtWj/COxRAjbV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAaYjAAoJEODzc/N7+QmaBy4P/2b9nLK7vn9E8a1rFiya+JOt
TIg+DsiJ/n4hKgSGfzpWlt/OA1oNqkAPGg+8FbjzEizOOJyYGVuork2GKI9K3XvY
8+pTgC/v8LoyIK7bKc6As0dtDz7iYzNBrgsFIPzLv6mgz8w6iwoQA8EcR8Q1f0gj
pk8PnAY73oyNSsXNlqNamuYIK8vZGnqfQZqJvMbs9sBBpG6R/6uLKdUjTSb74nNZ
yxjCigP81yuDx594vHzZEPYvdMPbiM7lTq5IEHMWbUDc1du9bpoAvycsS791vi+E
rYvbbKOweMhmItopEW9aA1wyVpBv0o0i2puipdoV4jW5h2PsaZ4KU55dk69odeu0
q83sIeKtiG7ImyRA5L9nTbJ/mULV/wrP9ZHhhGirEJVd5d8qFXgisdH3JLZoueqd
lLZHn1zlxYEz4CbaXfeu00BIwd03nGS8X68Dprc7H8wH/pko1+1zreVML8euQVPO
/ccuZkvmfNElpogzF/oz/c4uAMfKTS5C0pJXl9vqgbfYw4Zf1XmFoKcnfBGfnTc6
WDAScVmy9y+krToMk3vb7Tn/CfRNyeB5Em2IJcT+Y29h+iqbxreN3RV05XLPxBqi
6/MP8PVxvVt0VQGZtogC+ochUGUDAvIOY9CzHNqMV0Pi5k4stD59u1cCfehhPOQo
+0oElf8EICv+a1v+Kqnk
=IVKC
-----END PGP SIGNATURE-----

--=-O+qeE3SDtWj/COxRAjbV--

