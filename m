From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: ehea.c compile error
Date: Tue, 1 May 2007 14:48:26 +1000
Message-ID: <20070501144826.87e51386.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__1_May_2007_14_48_26_+1000_p81iknVGQGLIt+1M"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:42114 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754071AbXEAEsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 00:48:00 -0400
Received: from localhost (bh02i525f01.au.ibm.com [202.81.18.30])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by smtps.tip.net.au (Postfix) with ESMTP id DCB22368007
	for <netdev@vger.kernel.org>; Tue,  1 May 2007 14:47:58 +1000 (EST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__1_May_2007_14_48_26_+1000_p81iknVGQGLIt+1M
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Linus current tree:

/home/sfr/kernels/linus/drivers/net/ehea/ehea_main.c: In function 'ehea_hash_skb':
/home/sfr/kernels/linus/drivers/net/ehea/ehea_main.c:1806: error: 'struct sk_buff' has no member named 'nh'
/home/sfr/kernels/linus/drivers/net/ehea/ehea_main.c:1807: error: 'struct sk_buff' has no member named 'nh'
/home/sfr/kernels/linus/drivers/net/ehea/ehea_main.c:1807: error: 'struct sk_buff' has no member named 'nh'
/home/sfr/kernels/linus/drivers/net/ehea/ehea_main.c:1809: error: 'struct sk_buff' has no member named 'nh'
make[4]: *** [drivers/net/ehea/ehea_main.o] Error 1

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__1_May_2007_14_48_26_+1000_p81iknVGQGLIt+1M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGNsafFdBgD/zoJvwRAqVDAJ99ImSN+BExiOhq5I4ZaqPOFFBD5gCgju9x
PF3IMCuuh87gadM6haYVUEg=
=ymcJ
-----END PGP SIGNATURE-----

--Signature=_Tue__1_May_2007_14_48_26_+1000_p81iknVGQGLIt+1M--
