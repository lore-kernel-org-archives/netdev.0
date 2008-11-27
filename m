From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] ethtool: Manual page corrections
Date: Thu, 27 Nov 2008 04:16:19 +0000
Message-ID: <20081127041619.GL15344@decadentplace.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FUFe+yI/t+r3nyH4"
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:1708 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbYK0L0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:26:11 -0500
Received: from womble by shadbolt.decadent.org.uk with local (Exim 4.63)
	(envelope-from <ben@decadent.org.uk>)
	id 1L5f0a-0000Hz-UW
	for netdev@vger.kernel.org; Thu, 27 Nov 2008 11:26:08 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FUFe+yI/t+r3nyH4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Fix the following nits, too small to deserve separate patches:

There is a separator missing between -K and --offload.

The first mention of -p says the long option is --blink, but it's
really --identify.

The [N] following -p has the brackets in italics, not the N.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
The first two of these were spotted by Debian users and I caught the
last when fixing them in the Debian package.

Ben.
--- ethtool-6+20080913.orig/ethtool.8
+++ ethtool-6+20080913/ethtool.8
@@ -158,7 +158,7 @@
 .B ethtool \-k|\-\-show\-offload
 .I ethX
=20
-.B ethtool \-K\-\-offload
+.B ethtool \-K|\-\-offload
 .I ethX
 .B2 rx on off
 .B2 tx on off
@@ -167,9 +167,9 @@
 .B2 ufo on off
 .B2 gso on off
=20
-.B ethtool \-p|\-\-blink
+.B ethtool \-p|\-\-identify
 .I ethX
-.IR [ N ]
+.RI [ N ]
=20
 .B ethtool \-r|\-\-negotiate
 .I ethX

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at once.

--FUFe+yI/t+r3nyH4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJLh8T79ZNCRIGYgcRAo7bAJ90Lxm/84droPrbxYSm56PKQBWyfQCgy55L
z+WW8B1xj8zyF0sxx0D9IoA=
=w7jI
-----END PGP SIGNATURE-----

--FUFe+yI/t+r3nyH4--
