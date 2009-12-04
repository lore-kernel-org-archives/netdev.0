From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pcmcia tree with the net tree
Date: Fri, 4 Dec 2009 14:53:40 +1100
Message-ID: <20091204145340.a5b73373.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_Dec_2009_14_53_40_+1100_S.63__7UqXVCg8bS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:60450 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846AbZLDDxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 22:53:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__4_Dec_2009_14_53_40_+1100_S.63__7UqXVCg8bS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dominik,

Today's linux-next merge of the pcmcia tree got a conflict in
drivers/net/pcmcia/xirc2ps_cs.c between commit
8e95a2026f3b43f7c3d676adaccd2de9532e8dcc ("drivers/net: Move && and || to
end of previous line") from the net tree and commit
dddfbd824b96a25da0b2f1cf35c0be33ef2422fe ("pcmcia: convert net pcmcia
drivers to use new CIS helpers") from the pcmcia tree.

I fixed it up (by using the pcmcia tree version - since that removed the
conflicting code that was modified in the net tree commit) and can carry
the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__4_Dec_2009_14_53_40_+1100_S.63__7UqXVCg8bS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksYh8QACgkQjjKRsyhoI8wxKgCfeEcwHclW2NDisuPUf4PIDQ8M
GwUAn3YwHni1kQ62ZQeLdfFdw7g8TJ3y
=UPb/
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Dec_2009_14_53_40_+1100_S.63__7UqXVCg8bS--
