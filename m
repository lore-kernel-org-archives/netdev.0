From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: S/G operation, skb checksums, data copying
Date: Sun, 04 May 2008 20:58:03 +0200
Message-ID: <1209927483.3655.23.camel@johannes.berg>
References: <1209925725.3655.15.camel@johannes.berg>
	 (sfid-20080504_202821_526459_C1C8EB56)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UKKlIBWuvwW8SBs5Equa"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209925725.3655.15.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_202821_526459_C1C8EB56)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-UKKlIBWuvwW8SBs5Equa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> However, mac80211 needs to change the skb header before the skb is
> handed to the hardware. Often enough, the skb it will get is cloned, so
> it has to copy the header. Hence, it would benefit from having the
> actual skb data not be in the header, but that is unavoidable currently
> since we have no checksum features.

I just realised that this wouldn't happen since the extra data is
actually in a struct page *, so never mind.

johannes

--=-UKKlIBWuvwW8SBs5Equa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB4HOqVg1VMiehFYAQKGoQ//SDoLYkJv6vAIOVoythT9++2WMuCwrYjd
SIT3NBjq89oWbbSFyG/0LlgzTYH1U365aoX2zSOY+GL4KrT3njI4LSYTSZWaPvyg
J2hrX5IuI1iwmX5OAPyoMNy78LE2TOy2N4XAFkkraIXik1bKEj4eoVkXsI8tgtaX
uQvistl487tKt2bMbeWpWLQHItflaUJs81ANaEo/NAC/qHurxbJZ8xzDhSsWYQgc
tuKfvzrQNqkGYJAHnGSata1OfubaYPdnr9jHUbtyvzVvWPtAxPdOEXPIrvDOx0Hi
UkJZswW3xe50Po/UALimkOY8lyG6rGB7ILIhEYcOa8hh8xMEt62eP9vxMjgiaJkt
MxP/VV3GK1XNWH9VamwRfcVAnwpAfeeKpoCCPSus5bQglTnibyD3KekTx/XuV+zQ
VXxfURv5lzQET/5t/uNjm0glc4CiJ1OFdGihD8OuN8Lt1k3YTW1YN2Xh5gb55HhA
ATxl2/7Du6xCYECdOduZYW3ssx2EdtonuBD29pNd7T6TY3nxayf3sA/lX+gusSc6
tYf1jeTxDHhNEMxSB4Vt4KIxdDJPv/nLwqZViOSzaQjgZ9w0vZcmLpt6llvKbwKw
OQs3VhsPgTGVktoz1DkinP9Tn7tVy7NorpSmEi1+aqKzJzm+rvj14O8MREZV87yr
uxbx1ayinp8=
=G7QG
-----END PGP SIGNATURE-----

--=-UKKlIBWuvwW8SBs5Equa--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
