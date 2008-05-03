From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 01:15:39 +0200
Message-ID: <1209856539.3920.1.camel@johannes.berg>
References: <20080503125940.GA26199@gondor.apana.org.au>
	 <1209830582.3673.8.camel@johannes.berg>
	 <1209855383.3649.3.camel@johannes.berg>
	 <20080503.160705.78111001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uXOp3gDz7F1eHgA2gWf/"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080503.160705.78111001.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-uXOp3gDz7F1eHgA2gWf/
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-05-03 at 16:07 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Sun, 04 May 2008 00:56:23 +0200
>=20
> > This was a stupid mistake, if you do it correctly it actually works and
> > so far has only triggered a single warning on my system:
> >=20
> > [  217.507048] SKB BUG: Invalid truesize (4294964120) size=3D432, sizeo=
f(sk_buff)=3D176
> > =EF=BB=BF
> > that was with my patch though to update skb->truesize during !skb->sk
> > pskb_expand_head() calls.
>=20
> Thanks a lot for tracking this down Johannes.

No, no, I haven't. The only thing that was a stupid mistake was my
change to check the actual allocated skb size in the truesize bug rather
than do the < len check... That works, when you do it as in that patch,
but the mac80211 stuff still stands (along with all the questions I
posted elsewhere in this thread)

johannes

--=-uXOp3gDz7F1eHgA2gWf/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBzyGqVg1VMiehFYAQLltRAAksORUg1lPvtZBYKAk37ay7Opwj2xraT4
IoLYUP6T+Sy7jIHhdnHs3M3yIqtqPhkKbmCV0MysV2h6tsLyKYK8t/1vwgKQT6PH
AR4A5dVZtwdgq0FB8lC53VaoU19IBVT+H+gjMXrKZnnQY+//ObtYzeNfU3SA4AuO
RlNhZW8LQxmzBYUPSE6lsBezQewVr/FJq3Y+WETH4ehJPaI8B/pEGK03bS2YAOld
pAM9qv65mJcF7yg0i49MjQDqTn9lxybtqzVT0wiMGjUkaSRLpJE0Ii20MypiKOTd
P4Bf4+1yoRi+5HMqjB88GRyg0jDFIeHDHt7HkA+NNYgCojV4VUTaJR6wDBd8hsnY
/SpqL+WjDjNRwaAmfODOZNcfxRmXYJlp650H99V/DRgcZWYRhlm3HgS+odyUane2
AE195YLweySs6ff44ehBW9P/fhILueaAe7pndnnTF+fb0RIVQ3Sn+PVs3pyFbUn8
QAAjMPSoqRDn9cQzsN0WKwG6fR85pDnCa6dIjHnqRedKMvnyAUOcd9I22uH213T0
gjbnmd0M/f3U/kMscxzyc3FgpfrkTBRRmxelcemDVO+5IatoVQVDBuOVmAbarQWY
uqR7N8A8/xdheMwVXT24r5GhwKWCS0D1DedQdhwJVYoVAUmebAcf6afuzFJLeGB1
7QUHcWqYBYs=
=8kcV
-----END PGP SIGNATURE-----

--=-uXOp3gDz7F1eHgA2gWf/--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
