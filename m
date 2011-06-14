From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: [ipv6] valid_lft and active connections
Date: Tue, 14 Jun 2011 12:39:41 +0200
Message-ID: <4DF73A6D.1050809@samba.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig85EB08868EC731408C6E43A5"
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:37297 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab1FNKjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 06:39:47 -0400
Received: from [IPv6:2001:470:9f11:11e1:7d79:b5d5:2232:4647]
	([2001:470:9f11:11e1:7d79:b5d5:2232:4647])
	by post.strato.de (cohen mo3) (RZmta 25.18)
	with ESMTPA id g00fafn5E96nYU for <netdev@vger.kernel.org>;
	Tue, 14 Jun 2011 12:39:45 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig85EB08868EC731408C6E43A5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I have the following problem:

If I use ipv6 addresses with valid_lft !=3D forever, the ipv6 addresses
are removed from the interface if the valid_lft expires, even if there're=

established connection which use with address.

Would it be possible keep the address until the last active connection
is closed? Otherwise the usable of the privacy extensions will make
very long living tcp connections impossible.

It would be also ok to add a new special value "used" similar to "forever=
",
which triggers the modified behavior.

metze


--------------enig85EB08868EC731408C6E43A5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk33Om0ACgkQm70gjA5TCD+fvACfR9rxWsOAPksF45dkXVuXZLhe
V04An1Sc4qRBsVehbkZ3fKc7QyQG6/VK
=LiNY
-----END PGP SIGNATURE-----

--------------enig85EB08868EC731408C6E43A5--
