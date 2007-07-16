From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Mon, 16 Jul 2007 10:45:45 +0200
Message-ID: <1184575545.15112.0.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
	 <1184320965.30334.2.camel@johannes.berg>  <20070713110534.GF5328@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mm+nRoCVK/UYFT/q5Vx+"
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34148 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756209AbXGPJf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 05:35:57 -0400
In-Reply-To: <20070713110534.GF5328@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mm+nRoCVK/UYFT/q5Vx+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-07-13 at 13:05 +0200, Jens Axboe wrote:
> On Fri, Jul 13 2007, Johannes Berg wrote:
> > On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> > > I'm seeing TCP connection stalls with current git, and a bisect found=
 the=20
> > > following as a possible cause:
> >=20
> > I'm also seeing stalls with synergy.
>=20
> Please try the below.

I usually see stalls sending data from machine A to machine B. I just
upgraded machine B to commit 8d9107e8c50e1c4ff43c91c8841805833f3ecfb9
(Fri Jul 13 16:53:18 2007 -0700) and the tree includes this patch. This
did not, however, fix the problem so I guess the problem is on the
sender side. Due to wireless-dev lagging behind I there still have
2.6.22-something where this patch doesn't apply. I hope John will merge
again soon and then I'll report back whether I still see the stalling
behaviour with a current tree that includes this patch.

johannes

--=-mm+nRoCVK/UYFT/q5Vx+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGmzA5/ETPhpq3jKURAo53AJsHUboxUdV6PgEdFOGJOlSZIP+q0ACfep30
4S7dA9i8w0r6Pd9hJwbtLac=
=kTZ2
-----END PGP SIGNATURE-----

--=-mm+nRoCVK/UYFT/q5Vx+--

