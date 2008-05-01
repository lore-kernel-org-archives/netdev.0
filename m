From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 11:32:29 +0200
Message-ID: <1209634349.4008.15.camel@johannes.berg>
References: <1209607368.7173.20.camel@johannes.berg>
	 <200805011058.40197.mb@bu3sch.de> <1209632886.4008.8.camel@johannes.berg>
	 <20080501.022041.213526595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5hyj9nEcbOCeMbQPv+bL"
Cc: mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59081 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbYEAJdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 05:33:09 -0400
In-Reply-To: <20080501.022041.213526595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5hyj9nEcbOCeMbQPv+bL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-01 at 02:20 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 01 May 2008 11:08:06 +0200
>=20
> > > Seems the skb->destructor messes it up.
> >=20
> > Actually, it seems to be outside of mac80211, I put in a WARN_ON() and
> > got this:
>=20
> You're just seeing who freed it last here.
>=20
> It could have had it's ->truesize put into an illegal state
> elsewhere.

Yes, I know, but it doesn't come from my skb_orphan() call. Hence, I
just =EF=BB=BFnetif_rx() the packet which makes it go onto the input_pkt_qu=
eue
and then to netif_receive_skb() which gives it to af_packet and all
others should ignore it since I set =EF=BB=BFPACKET_OTHERHOST.

johannes

--=-5hyj9nEcbOCeMbQPv+bL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmOLKVg1VMiehFYAQJMaQ//SCvIESq3jYrUzS0z3+P5HnIN2o4WEucW
JJO3L0A/MTMPsX7oq56JU0YzaU7VtxR0EVIHWt2lOwXBlbdA1oV0p1ymgUVYvRh0
iW9wJzZFvFlRbLl5zDXp7xTvaaRejP7IWp9JYzeY4qX2pOdFLzLBBL8o4LhEGx/z
g+SlYOTzoSEDPe88W4sLaLXgw/ofRDN7obbx8AX5xlrudzKg8Fgk7TYCZYbfISLP
X7q9vVlqJZq8+l0PY/LJ/OPP2oS/h0X6LA6Jpk5u94G6yLfpdHoX5AalWXQwaBmY
blfWZJDYtqBGxiVUJza4SlchYUJ/IQZC6VhYh4IaOJKDScPDGCCNOgqMCwT1Lvri
xhP8/rVohfVmo0DFPcwu9/IJ7B0W+Rq+7LKjMU9WLPjPe30oefyWCyag/GeHd5lV
pexIR39GTdKc29HeLKFO6P1kk9Jfj+lJ76MCx5djlg7+b2irrPgL8h8Q0a5Z7DeR
N76vpGH+q3tAJhQyLsWpTDHXmGr+EflBTtB2VxbejorZiT2EM5RyQPq9D/nqY+y3
Mah6qmWcjmRt0nSSV6I/uwJzzrPNncC7PGYJ81bfyZPhbdIpZQbwswUCibJdmqJI
9caz4uY5bU5CYXTpg/Dez47S0SbeF4mOtDcGcldi0gNQQgZKltLT2n2hYrk4MYgF
PES/JvOcsD8=
=LoW7
-----END PGP SIGNATURE-----

--=-5hyj9nEcbOCeMbQPv+bL--

