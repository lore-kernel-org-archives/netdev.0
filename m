From: Mario Limonciello <mario_limonciello@dell.com>
Subject: How come realtek drivers are combined
Date: Thu, 26 Jun 2008 18:16:42 -0500
Message-ID: <4864235A.40807@dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig303A2B7EA16C670391A06330"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:6717 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbYFZXQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 19:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig303A2B7EA16C670391A06330
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi:

I'm new to the list but didn't immediately see an answer to this in
quick searches.

Realtek provides several (separated) drivers for their different
chipsets, r8169, r8168, r8101, etc. I see that they are regularly all
merged into the r8169 driver in the kernel.  How come it works this
way?  Is it just because no one ever bothered to do it differently?=20
Obviously, they all share a very similar code base so its somewhat
sensible to try to produce a single driver.  I would think it would work
a lot better for everyone if Realtek and the kernel maintainers that
work on the Realtek driver were directly in sync rather than having to
play tag pulling patches from each other's drivers.

Thanks,
--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enig303A2B7EA16C670391A06330
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIZCNa2CrZjkA73YsRApjgAJ42pCxwUJ+WvNxnfpvfOulf0fOrUACeKHch
PFXC6MU3alM8nAp2nRSeEHA=
=uX6c
-----END PGP SIGNATURE-----

--------------enig303A2B7EA16C670391A06330--
