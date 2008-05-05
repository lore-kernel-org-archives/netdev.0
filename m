From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 06 May 2008 00:44:07 +0200
Message-ID: <1210027447.8012.15.camel@johannes.berg>
References: <1210018214.4181.27.camel@johannes.berg>
	 <20080505.134420.194001886.davem@davemloft.net>
	 <1210021066.4181.41.camel@johannes.berg>
	 <20080505.153730.186617868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JCrzFm5tGATrOBhgOvbY"
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33556 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764060AbYEEWo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 18:44:56 -0400
In-Reply-To: <20080505.153730.186617868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JCrzFm5tGATrOBhgOvbY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 15:37 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 05 May 2008 22:57:46 +0200
>=20
> > But I cannot modify the ethernet header that'll live on in the skb data
> > so that's not useful.
>=20
> Actually, you can, if skb_header_cloned() returns false.
>=20
> When skb_header_cloned() returns false you can change the
> headers however you like.
>=20
> I'm not sure if it helps the bridging case or not, but in
> any event, the following patch should work and reduce the
> number of cases where pskb_expand_head() is necessary on
> TX.

Right, that makes sense. But will it ever return false? skb_cloned()
returns true often enough, and we only accept linear skbs, but I think I
don't understand yet what skb_header_cloned() vs. skb_cloned() refers
to. Which exactly is the header space I'm allowed to modify when
skb_header_cloned() returns false?

johannes

--=-JCrzFm5tGATrOBhgOvbY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB+NtaVg1VMiehFYAQIhyQ/9GuNcaKx0zmTXy1LXbVDmBC+dCJo9LIky
A0P5toUodoN4FkrwVhttExnnhkvjNicYbs+YzJyIOxjKvqBZjY8gmYe17BBibpnE
5fcsgVPg0gOh96oYaqAkmitEYt3+yQ3sZMo5MhRhE7O1ug7BuChsqQKbktAPQv9g
GsRvXAisUD1/j0wxj5gia1S2byo+oa+PQw/Pnp+Quld1IDgQ3I2wU/+pB0pM5LT8
OpRr7ogGOmIbGw6jny4aDwDsyiyvuELlLssMJnpCyLxvAdxtLzuZ9K2VvL07zmfB
wOZf5QDNtH7RlGD8g0psZTsk8TPBa1Bpa2B4ZFDiYd6JejgYr7UKyNaLODOWqC8l
v2Yy+4sySnJnl5NKLK2JGRNxcvoEYobxKXoGrtTJrKLOeFLYKUMPWeOZHa+6UKX5
WWVsaOepTP1iM7Q/viRhsV/2C7OQuM/ua2htO693Zk9PzYtB9lBP0n3mmDkB8DMo
hq78D/U1pEcj70u0PetuyN22z5xE8r+4Z9aEOxS75Fj73IbvHmBjnLe/hElEWBre
oUQzR9DsacUI/K/5deFelMh/Xvnt25NYJEFRlynRn8UmyBH1nRq6t0lTr/k1SDDz
lnA0eTiH7QZArDMNwNE4P3/kWpy2/yplZ8PZCRNPROrIovd9BtzWtiGgl9pYkcBw
mfxz5HQc4lU=
=l5/x
-----END PGP SIGNATURE-----

--=-JCrzFm5tGATrOBhgOvbY--

