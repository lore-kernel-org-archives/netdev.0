From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: NET: Questions about supporting older kernel's with kmods
Date: Thu, 19 Nov 2009 09:21:45 -0500
Message-ID: <4B055479.8070101@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig87BC562EEA99524E08FF33E3"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:59572 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbZKSOVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:21:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig87BC562EEA99524E08FF33E3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi All,

So I was in the process of packaging up my venet driver so that it could
not only support the in-tree build (in -next), but also build as a KMP
for inclusion in existing distros that already shipped (like SLE, RHEL,
CentOS, etc).

The problem I ran into is that the ethtool and netdev_ops components of
the in-tree version do not necessarily align with the substrate
capabilities of older kernels.  What are the best-practices surrounding
this issue?

Q1) Is there any official CONFIG tags (e.g. HAVE_NETDEV_OPS) I can key
off of, or should I simply look at the kernel version?  If the latter,
any recommendation on what to use for the aforementioned features?  (I
can always try to git-annotate to figure it out, but I wonder if there
are best-practices already in place).

Q2) Is it considered "bad form" to include such compile-time directives
in the version of the code going upstream?  E.g. can my driver in -next
have "#ifdef CONFIG_HAVE_NETDEV_OPS" or other version/capability deps,
or do I need to patch these externally into the code destined for the
kmod, and leave the upstream code "pure"?

Thanks in advance,
-Greg


--------------enig87BC562EEA99524E08FF33E3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksFVHkACgkQP5K2CMvXmqEx6ACeNFgKO8X0f3TYAPcoenc11yRf
ungAn0JhYG23/1XVsJcMfn0gqbvBTPeB
=P0ZY
-----END PGP SIGNATURE-----

--------------enig87BC562EEA99524E08FF33E3--
