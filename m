From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 14:48:23 +0200
Message-ID: <1209905303.4065.20.camel@johannes.berg>
References: <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 <1209900355.6210.64.camel@johannes.berg>
	 <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pT1LkiG4nSlouIyW10iU"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504124542.GA1455-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-pT1LkiG4nSlouIyW10iU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Right hard_header_len is being overloaded with two meanings.
> On the one hand it's used to indicate the length of the header
> managed by the hardware header cache, on the other hand we use
> it to indicate the head room for those devices that don't have
> a cache.
>=20
> Since your device wants both, it fails miserably.

Yeah I guess that is actually the root cause.

> There are three ways out of this.  You could have your own cache
> (I haven't looked at your headers so I don't know whether that
> makes sense), have no cache at all, or add a new field that gets
> added to hard_header_len for the purposes of calculating head
> room.

In fact, I should probably add another field for the needed tail length
too since we need that as well.

johannes

--=-pT1LkiG4nSlouIyW10iU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB2wlqVg1VMiehFYAQLksQ//UFIWoH5yvL0itxrX+j+HGNHf+yFJHetE
9y5NNQkmnDRhYsCmC/4Zb4x9SICMIcHnnyDZJsfkyeABGfvOIQFohtbLU3GRk1tX
m62FZhz8Zd/+R4cy1MgDOBOGlujYEJn07lWOGD8H6eqWpKHcFkakGp3/xjRDcJq+
EeAYED3nKFeecgdptRvBpJVq1K5BmXQWI8TKDI9g1JSTtQPYLbS5S2nX+NrUMMn2
R87KU3jwXGJ/MJLJwopN7CBg5mmrUJfK9Irz1HpCeWCwcHA7vHU5V5tMicNXArzC
Bmtb2ygBbEho7V/3MyipThSSIR6/+JIShOEQup9pa1dmutNv/qXeIzK6cooMn3Hk
6a2D5nl2iMRkFQFs/hJ0IzHue/5aqXvsskHrWlDgZ/tPY0yCAgQa/LW1/UJY61nb
c3QY+7eOYyAWMqvxLxyMTyx3VfJC6qUyIzAK/2KYVKWHU427xDL+TSs1v3IrD5IL
m+y3A07hZ9Co34vqbJERNlt2bhg19YTbgoPZL/f0KMC6RFQ333nWUlM8YUDoJGze
vahVHbuOaWfE85MmzpvfNhkGrOsGi/uat5VLERs7JaSnoriIMiFzPleydGu4ux+E
KkjbUdFJuLopMjwrbCUtIEhAQ/zDUHV4/E91gWYCV1eqEhZtGSiIRTVbxAfL7Lv+
ZtCxA/ZsOzc=
=h0N6
-----END PGP SIGNATURE-----

--=-pT1LkiG4nSlouIyW10iU--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
