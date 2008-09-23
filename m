From: Johannes Berg <johannes@sipsolutions.net>
Subject: G5 with tg3 ethernet stops when rsyncing large amounts of data
Date: Tue, 23 Sep 2008 16:44:58 +0200
Message-ID: <1222181098.18015.23.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-l/a1uyVQp3AcF4OIShyc"
Cc: netdev <netdev@vger.kernel.org>
To: Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50067 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbYIWOpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 10:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-l/a1uyVQp3AcF4OIShyc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I've been trying to push a few GB of data from my powerbook to my quad
G5 with rsync, but after transferring for a bit the machine stops
entirely. It doesn't even reply to ping, so this must be happening in an
interrupt.

The only information I have so far is a picture I took of the console
when this happened again:
http://johannes.sipsolutions.net/files/dsc_2275.jpg

Unfortunately, there isn't even a backtrace for some reason.

johannes

--=-l/a1uyVQp3AcF4OIShyc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI2QDmAAoJEKVg1VMiehFYph0P/3kGl/VqhAnhhfS3RTpe2wG0
dkZjnIacqPxfxqTbiDcSoFZqliU/zfvOmoOYmDHY3+uN+2zXMCEooHWvriFt7XJQ
sBK9VNjJKZOfixcBvlcefELNFSrTNadNn3X/ZGHxNAiLVSZnBGewhyIIqeBNED/d
1d8Qav43IS20t4A7QhoAMVRcGL9L765p3UhyYbCQc8V3SOyeEORF6OeUuCwNAPMV
xYjDjU8zFNpNrifVVHujUxaV861G1Bnw1oQL0VFJ8LbJ7zzz3r32nPC7+NocqV59
rx000S0RPzj7ZWikj81GVxaYexSBhkDgb++9yzYoX2gjNM7IGDY9ZeGDd4Jwyyyk
Y4+PJG7g/H8nqWN4Qs1DOyvLdYdMtpcYGbXLu1hHAECUJqQ+w5NwUI4nLfAAhQVW
aj8/NHCoM67moaK18NyDCBOrQOSB3aUAd21JXQdR7SHUO7eejvT/BVlKqq4vq0Sq
z53Z6PIE9JXWBqgeCT9X97a8Q2RvdSqxqgFDQi7XCqTj1SyQdaCE19FQyk5PV5Py
NNDVnMYFYWHSMwoJPK/8vXs2WSs7MKrZnsXYRvLCQTaZEitAu/A/MnaGy8G8rJ4f
br90vwV+J8L/CM3fWDwt9uHzOgPygiTn3WF9isqtHlZWymAQpDpMcU7cW6phUbYx
Rev8W9yLTVnP+HzkgpZd
=CEXo
-----END PGP SIGNATURE-----

--=-l/a1uyVQp3AcF4OIShyc--

