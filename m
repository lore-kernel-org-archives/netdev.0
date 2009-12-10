From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net-current
 tree
Date: Thu, 10 Dec 2009 14:37:56 +1100
Message-ID: <20091210143756.5a236829.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__10_Dec_2009_14_37_56_+1100_CMTkHqMk8yQZ9WnF"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	=?UTF-8?B?IkFuZHLDqSBHb2RkYXJkIFJvc2Ei?= <andre.goddard@gmail.com>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:55892 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759277AbZLJDh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 22:37:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__10_Dec_2009_14_37_56_+1100_CMTkHqMk8yQZ9WnF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
include/net/tcp.h between commit 2f7de5710a4d394920405febc2a9937c69e16dda
("tcp: Stalling connections: Move timeout calculation routine") from the
net-current tree and commit af901ca181d92aac3a7dc265144a9081a86d8f39
("tree-wide: fix assorted typos all over the place") from the trivial
tree.

The former moves the comment that the latter corrects to
net/ipv4/tcp_timer.c.  I just used the net-current version and didn't
bother fixing it up in its new location.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__10_Dec_2009_14_37_56_+1100_CMTkHqMk8yQZ9WnF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksgbRQACgkQjjKRsyhoI8yG7ACfceolhrv9JxlGbpgdrIBMiKqv
ZhkAn3nlKsXyEQrIHIt7IkhpQ3E0cFph
=fvjq
-----END PGP SIGNATURE-----

--Signature=_Thu__10_Dec_2009_14_37_56_+1100_CMTkHqMk8yQZ9WnF--
