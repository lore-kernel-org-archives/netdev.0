From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 3 Jun 2014 12:31:04 +1000
Message-ID: <20140603123104.048d1bf7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/wbB6YTnblQWs4.z8NYf8xn+"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:52330 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbaFCCbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 22:31:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/wbB6YTnblQWs4.z8NYf8xn+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/output_core.c between commit 39c36094d78c ("net: fix
inet_getid() and ipv6_select_ident() bugs") from the net tree and
commit 73f156a6e8c1 ("inetpeer: get rid of ip_id_count") from the
net-next tree.

I fixed it up (the latter removed the code that the former updated, so
I did that) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/wbB6YTnblQWs4.z8NYf8xn+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTjTNtAAoJEMDTa8Ir7ZwVLp0P/RyNJi98kkj0HwD9Ba/eyhbd
/x/aCatGZmVNAPjGmd8vsM2/+cxEf9DH8p2ExlQj9nw7TztW5l6hfpG6hx6AN4On
kocQZkWUamn1FS5CP1fJTeaEhgNy6Du6meuT5LM0FpwysrHKbUHwzXVWPb7I65XV
wFBxU3YAen8dvqCl+nj/JDTYB0onwCRct1/MfAu5HzOhWaUUtSWvaYqI2ld7OL7f
iEtbdOU7AXVy8xVkz7S+MOiaPko3ZHRghkTeIqXbkroIutfeIGxiM2rypNfYmzqe
xJI0MFeZluzA5o35Tnh6gGZAePPoJ/7zG0Ka6QGQKSdxfQSjS/lff6vx+LIRymxN
Qi+y1+CmlJXHA5Q0gW6utsizDyyE0huVT9ejJSBvzpGBLyVSjxZr7hOufh+UT/sm
NhSe/hf/c8Mjei09Ar2rQy67q2Pd/EXNkZrFTICA/MgmAcpaWDiRBlibGP1xc9T0
G/t6Ahbtu4QMTGmW32MP0BjpCTgS3J/gvgLtsEWBTw2U1YGzmTrVYafXRhGdxp5z
rndoZtmQMjVJ7Mfnn1bzmX2fNMbtkdKh938OacG3tHsNATRi+eju5PUZEy+k2Myn
5AJwENwMMMVhKxpA8FZO25eXJj8TarFLFlcITCCkKD98zIIigExlyQ3jBY24ZfsK
bqquLqJOxca6SUGINBr9
=3G3F
-----END PGP SIGNATURE-----

--Sig_/wbB6YTnblQWs4.z8NYf8xn+--
