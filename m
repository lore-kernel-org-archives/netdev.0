From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Wed, 18 Jul 2007 23:24:17 +0200
Message-ID: <1184793857.8125.23.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
	 <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk>
	 <1184575545.15112.0.camel@johannes.berg> <20070716120247.GG5195@kernel.dk>
	 <1184711770.4658.5.camel@johannes.berg>  <20070718104916.GJ11657@kernel.dk>
	 <1184756332.4658.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BED9jqTFr30xxq8D14W6"
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35588 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764926AbXGSKFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 06:05:32 -0400
In-Reply-To: <1184756332.4658.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BED9jqTFr30xxq8D14W6
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-18 at 12:58 +0200, Johannes Berg wrote:

> Yeah, I only need to try to remember when I last *didn't* see the
> problem, and hope that my analysis about it being on the receiver side
> is correct :)

Hm. I went back to 2.6.20 on the receiver side and still saw it. Maybe I
need to go back further?

With strace (the synergyc process) and tcpdump (on the interface) I
continually see packets coming in but the read sometimes pauses for 8
seconds... Not sure why. Very weird, but right now I don't have enough
time for investigating.

johannes

--=-BED9jqTFr30xxq8D14W6
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnoUB/ETPhpq3jKURAv5eAJ9OrmI07SGfQpNi0LN+OxFJDuoOIACeOSvc
O8eQrXVZ/+vfNvSx5YVaRrQ=
=SRTQ
-----END PGP SIGNATURE-----

--=-BED9jqTFr30xxq8D14W6--

