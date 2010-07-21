From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Wed, 21 Jul 2010 12:04:48 +1000
Message-ID: <20100721120448.31e325fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__21_Jul_2010_12_04_48_+1000_Bli2YTYNr394HT7F"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:40949 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762067Ab0GUCEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 22:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__21_Jul_2010_12_04_48_+1000_Bli2YTYNr394HT7F
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/bridge/br_device.c between commit
573201f36fd9c7c6d5218cdcd9948cee700b277d ("bridge: Partially disable
netpoll support") from Linus' tree and commit
91d2c34a4eed32876ca333b0ca44f3bc56645805 ("bridge: Fix netpoll support")
from the net tree.

The net tree commit seems to be a fuller fix, so I used that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__21_Jul_2010_12_04_48_+1000_Bli2YTYNr394HT7F
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMRlXAAAoJEDMEi1NhKgbsB90IAJEA6zRC7IhRzMFhCYX4h3uB
NmhdSyqlUXvb40MZHyp6gy9+hoMl82fEkN6Xw0kAckggwbrt2PfcZmR073jObRhw
7vyKRGqC946GGRHEuKHWGg6wCcAdfWraR3r49tnNYXsAz2niu7rzuwyfZy2NjS69
r9DMjk6fN5fiSDzmthyPUCxFV0B1vL0Tup292+NLEvefxywqI3VUd0V+IkXoVKNM
cvFnWkBha1Hsj3Wbi8KYABrbTNGYLsOvAoKpVzmnz8c4f8ozjlnf9WJHH8no3B5P
C0IHAxhn6pVzw4Y+sCwG7lTOWWeTxd5d2sxRtoA30gWB9N63pL/gFCY5+535Thw=
=e274
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Jul_2010_12_04_48_+1000_Bli2YTYNr394HT7F--
