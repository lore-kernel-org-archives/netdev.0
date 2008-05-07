From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 07 May 2008 21:19:49 +0200
Message-ID: <1210187989.5642.28.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <20080430130050.105344000@sipsolutions.net>
	 <20080507071026.GA24407@gondor.apana.org.au>
	 <1210150217.9305.39.camel@johannes.berg>
	 <20080507090040.GA25186@gondor.apana.org.au>
	 <1210159339.5642.13.camel@johannes.berg>
	 <20080507114123.GA26073@gondor.apana.org.au>
	 <1210161133.5642.19.camel@johannes.berg>
	 <20080507130548.GA26977@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9Axcf3WAuzXZ5Exyb1Em"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080507130548.GA26977-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-9Axcf3WAuzXZ5Exyb1Em
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-07 at 21:05 +0800, Herbert Xu wrote:
> On Wed, May 07, 2008 at 01:52:13PM +0200, Johannes Berg wrote:
> >
> > Hmm. Why does busy exist then? Historical accident? I really really
>=20
> Yes it's historical baggage.  These days the biggest users would
> be LLTX drivers which should all be converted to non-LLTX and
> drivers that don't keep track of queue status properly.

Hmmm mmmm. I'll clean it up later, it gets easier with my patch that
puts the control info into skb->cb so I'll do that later in a separate
patch. The way I see it, this is actually *correct* from a "what hits
the air" point of view and the current code is crappy.

johannes

--=-9Axcf3WAuzXZ5Exyb1Em
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCIA1KVg1VMiehFYAQKD2RAAhYKiUA0L9xunXFOq5N5Fq0jGs7oupoKa
d6JTl1GcPVCqRocOrFAzmYdIxePvJpx59fUp4r58/4oSU2HOAYX2jkzQhYPqxytS
r8/6Bx3kqsjlp0AdcMd636HtYquaG5vrxw8rbSgSF+5UqY/led5PTug8DIee8Ng3
2AjrY49ZDUcDGknb2wxxCsVigwO+Qyejf9W60hH/8pe/9vsqkR5aY3ihYC76b2lo
erHX31JrXVsaTFXlYpBVSaEpHZusyeufCGgD8PxsbfRwLON1iT9zJWaKhSpt+fzF
A2o/tQFN00TPvA2u7kEaOenJ2GpFGOHehi9PxZPWqxh9P7GszOmdrhofPc9k1MaG
ipWN9tsseFhLN5RFYoDzrfKPuqbKS3qJ4G9saK2/h3ojW3CYw8l8xfH4G+8V6EXN
2EWN71QMw9ruNnALHmG3P/aVI9GKydDXbDSg/jSWN1c0n+D9oNSlHf1/KgOqW8wn
bH211qdMmaCHoLkp8FtdeyZDkzEDH1xQjR0/elX4UsSC1nsCEjV6gvpyW5EJ5O39
b8ohxbe0S+DJOAMzlPfvvWemUl4tsaElFuNQnEIAWubtlu20Y6nmbEVHAyxah11S
PamYmt9fduuc5TEjk3+ZdlkrulBGBUdLdETH/9EGnsarzkgZaqLJzFwIcGPOqHrG
+zYEhdi+zFU=
=HlvZ
-----END PGP SIGNATURE-----

--=-9Axcf3WAuzXZ5Exyb1Em--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
