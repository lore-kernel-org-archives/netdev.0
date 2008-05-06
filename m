From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC/RFT 2/4] GSO: generalize for mac80211
Date: Tue, 06 May 2008 18:12:43 +0200
Message-ID: <1210090363.3914.13.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <20080430130049.359549000@sipsolutions.net>
	 (sfid-20080430_160737_937304_CEF0FFEA)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-r/RzRPeygPgPBlKd4oth"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080430130049.359549000-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20080430_160737_937304_CEF0FFEA)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-r/RzRPeygPgPBlKd4oth
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-04-30 at 14:40 +0200, Johannes Berg wrote:
> plain text document attachment (037-generalize-gso-functions.patch)
> This patch adds a new function dev_skb_segment() that generalises
> the existing dev_gso_segment() by allowing to give a segmentation
> function. mac80211 will use that function using the segmentation
> function skb_segment().
>=20
> This patch also changes dev_gso_skb_destructor() to be safe when
> the skb no longer has any segments, this will happen when mac80211
> has internally passed off all the fragments to the driver instead
> of asking dev_hard_start_xmit() to do it (which protects against
> this by resetting the destructor if it has sent all fragments.)

Any comments on this? I'd like to include this (well, more importantly
the mac80211 patch that needs it) for testing for 2.6.27, should I send
it via John or directly to you, Dave?

Also, I'm not sure, should I allow for a segmentation function at all?
I'm only going to use the generic skb_segment and the code there only
uses =EF=BB=BFskb_gso_segment.

johannes

--=-r/RzRPeygPgPBlKd4oth
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCCDeqVg1VMiehFYAQJzPw//WegcOkvAs3qWno9isRd/7BHveN7RKoHU
FOhTdUevkQjCmGL7S9OATsSEjqe5075CKp7byswXIHDUB7h5nxaqHQEFT9JjkXdt
1rDldSA0tJFk6tG6R644KbtTvChtvXcR+LGfjRzqSYGnulqHm752rNMj/5q8FGmu
hFMoeKW0uJKmu+ZMMHX/Tbj6rVq/4xVyms37x+3xBBC9nVLpe4+7zskW/CfCoRYy
C3QTTdfw7WLgiXCqA11jiRrBx5qBHOz4UaFf+JI9XU7fsMY7/Al0JbRYt0xEyRsR
om7NvBuAEeNyEUtgxKvFVSUce/H/aoy0xDhCz+CDqBsgIj99fZ30G/WpqliHBP+P
kPrCKzHMKlsm/kMWjuAjcLGWjraDVeV5Rz4ETsbhO3NOsWACGeck/QfuF9VgAChV
XiaDBL1BHAePVOk9BSGsbbjN+CM+V/QrIBY/Jodgw15LPL9VZZHT3HHEJmMt1UC5
j2+Yaw8ongTgzReFfHTMF8UKPW+nnWFwVCAGQdHrVahqCvKq+6UWNh6b6+SB6SvX
JBdhOULskqFf7StQiW33d/9TAeoW/fkOHRRR7fxJ46azfm3l0L/McFVHQ0MwzDt0
KUR5FmbaMoObydHZ1jxcVo1VEh1vJinLbYl0IkIAsn4bALhWPPuyW2ixuqyBvAOn
ZZEg2cn5gDk=
=4KJV
-----END PGP SIGNATURE-----

--=-r/RzRPeygPgPBlKd4oth--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
