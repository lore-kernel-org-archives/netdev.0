From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: [IPv6] Why does IPV6_ROUTE_INFO still depends on EXPERIMENTAL?
Date: Wed, 13 Jul 2011 00:03:21 +0200
Message-ID: <4E1CC4A9.5000204@samba.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE0D8ABB161F60B72774EDB34"
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:15561 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1GLWD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 18:03:27 -0400
Received: from [IPv6:2001:470:9f11:11e2:b73e:2c81:77fd:3603]
	([2001:470:9f11:11e2:b73e:2c81:77fd:3603])
	by smtp.strato.de (klopstock mo44) (RZmta 26.0)
	with ESMTPA id j06da8n6CLUBeG for <netdev@vger.kernel.org>;
	Wed, 13 Jul 2011 00:03:25 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE0D8ABB161F60B72774EDB34
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I'm wondering why IPV6_ROUTE_INFO still depends on EXPERIMENTAL about
5 years after the initial implementation?

I'm also wondering why IPV6_PRIVACY, IPV6_ROUTER_PREF, IPV6_ROUTE_INFO
are compile time switches at all, while there're runtime switches which
are of
by default.

It would be nice to have more IPv6 features enabled (at compile time) by
default,
so that features can be turned (at runtime) with default distribution
kernels.

Is there a chance get patches accepted, which remove some compile time
switches?

metze


--------------enigE0D8ABB161F60B72774EDB34
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4cxKkACgkQm70gjA5TCD/QvwCgxfRetglogQc1mWmYnhnn4pRa
0SYAn1Ivg/j7vyhvWJA9tTbNulzHXSQ/
=lP6C
-----END PGP SIGNATURE-----

--------------enigE0D8ABB161F60B72774EDB34--
