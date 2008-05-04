From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 11:52:34 +0200
Message-ID: <1209894754.6210.58.camel@johannes.berg>
References: <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 <20080504020203.GA30514@gondor.apana.org.au>
	 <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nW8izu5q2PhVnX6uOKM5"
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43002 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbYEDJws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 05:52:48 -0400
In-Reply-To: <20080504094444.GA541@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nW8izu5q2PhVnX6uOKM5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 17:44 +0800, Herbert Xu wrote:
> On Sun, May 04, 2008 at 11:14:49AM +0200, Johannes Berg wrote:
> >
> > I just re-did the test, and I definitely need 29 more bytes on, for
> > example, the IPv6 autodiscovery packets and ICMP packets generated with
> > ping(8). Some of them even need additional tailroom.
>=20
> Could you find out the code path that created the skb in the
> kernel so we can see why there isn't enough head room?

Yeah I was just considering putting a stacktrace into the skb when it's
allocated. Haven't done, lunchtime now.

johannes

--=-nW8izu5q2PhVnX6uOKM5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB2HYaVg1VMiehFYAQKdlxAAleEcN8BBFVgnJQmpB9lmft8fLD+Qxxns
H/alt2Xu+3GlwHF7rRtPAH7YOI4x9u1pJeGIsMLV4yRQk5ykxfayAQfpxR2M4ZlW
es+a4Ax5zGXoQHjmRRBz9LSKe3XV4XdSN51cv71Q051hSjBXSeQxTXTdeiiwMxsi
08Xm3hP4DrnmBTw0vodJt4BHBvYeogCPcm53o7lMgkPIdNaWx/raIihNiPF1PR+N
YO5H+P+o2n8k8aTB4qap52vonxUi/0Dlz/zPscmeANCS9PJL0N+l464ln77SELH8
vOaB3EO91XCb4iSoxnPSFaB4cUTtoWwcOUaTpfqN2S50FqVg3SLoxaCJEQpwUo+O
SMtIYJER7y/6jUAFHfZwjsUXXvC0iWvNyrxrzWhYp5iewHyI8iV/eBPpevWXimle
7XNzvLRayxXiS+YcLUtULyXMCfgVvQeqZFwxUmh6L3rot/SDIyK5tcqr6Dl3EQ4Y
Te8uY67RYiopPvQOHgjc7kMnv1kVi0AxpVqThhniKg3gQAtkWkX392GNHpqtemNU
o8a7xYjsYETFMMXdk86q9xYqVBvsUEGrhDzekrpMZ0LPpnS4qz6B0fB+0EI05ipP
9IzttdHa0J5OIpvct5ZA2A68ADy1bu2tB1Hlq/AyD+3v8O1oyYoZ1Wb2JMHI5Izw
nGz9ffoOA8w=
=0Rsz
-----END PGP SIGNATURE-----

--=-nW8izu5q2PhVnX6uOKM5--

