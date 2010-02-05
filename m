From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Fri, 5 Feb 2010 16:50:59 +1100
Message-ID: <20100205165059.0b5d5363.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__5_Feb_2010_16_50_59_+1100_b8V.lbLiILDVfOYJ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nick Nunley <nicholasx.d.nunley@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:49697 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab0BEFvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 00:51:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__5_Feb_2010_16_50_59_+1100_b8V.lbLiILDVfOYJ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the scsi-post-merge tree, today's linux-next build (powerpc
allyesconfig and i386 defconfig) failed like this:

drivers/net/e1000e/built-in.o: In function `e1000_has_link':
(.opd+0x1d58): multiple definition of `e1000_has_link'
drivers/net/e1000/built-in.o:(.opd+0x588): first defined here

Caused by commit b548192acaebcb05d6a87d1e94f19835b1a18a8b ("e1000: Report
link status in ethtool when interface is down").

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__5_Feb_2010_16_50_59_+1100_b8V.lbLiILDVfOYJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktrscMACgkQjjKRsyhoI8x6hACbBLrjSzG6pb8CdOzoEyvDgLwE
IO0An1FaPxClHjS/3D0zWdarMYLtL/N+
=tScb
-----END PGP SIGNATURE-----

--Signature=_Fri__5_Feb_2010_16_50_59_+1100_b8V.lbLiILDVfOYJ--
