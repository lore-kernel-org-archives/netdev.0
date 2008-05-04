From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 04:09:46 +0200
Message-ID: <1209866986.6210.41.camel@johannes.berg>
References: <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 (sfid-20080504_034221_325997_0547A6E8)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zfg8D9pxGIM6OLTwM5ek"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209865354.6210.23.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_034221_325997_0547A6E8)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-zfg8D9pxGIM6OLTwM5ek
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Ideally, we'd have enough headroom in the skb to start with, since right
> now we're apparently reallocating a lot, especially encrypted frames.
> Not that I understand why we don't get a truesize bug (without the
> monitors) when we do that.

Hmm. I wonder if the reason might be that the skb itself is long enough,
but has so much tailroom that it doesn't have enough headroom, but when
we reallocate it to have more headroom we actually later don't use the
extra tailroom. That would explain why I don't get truesize bugs
although I do get a warning (from the modified pskb_expand_head()) that
I mustn't reallocate the buffer.

johannes

--=-zfg8D9pxGIM6OLTwM5ek
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB0a6aVg1VMiehFYAQKbNBAAth0Q/uwPYlqHMVHmGo7+ouTYVzDgwACH
Sv+xWVeBjOeeWrJB5aThhWhMKSJQORrsFogUQF1yYriXNPZAWBDW2VOjA/QhKEIP
imJ5kZC9PvRyai85L8n83AUGM5xIsZwr5AxMCy3/xlxanjFV5Ct8DiD91WELEcpi
35XEWQxFzB57tDONC5dEJvnLudWE/DeDAnxtwOPxfouxu1rt5ho8lpg0QujH5fWB
iruGf1/YIUw4RYfjSapK06wfxdP2nYGVia+B6Vex/CHbTrlcHNfJ/k0WYPzuMN/C
QVoJyoKEJvB2Pu3vXTStvOvVXaSvk7kRxeunNqwVdS6yG6Gaxaws0lOc/yWga8lR
jOHY+qLTKEyvH5M1JQL4pqH0nZzEIA6qCBBp9toUqgdC7UAXDM/v7ea8lj2diNi2
sgF9W5WyF5Dn1/Qfl7kQrPA6ASDD2anuZOnrurYvs9BVUovg+T0PGi6GClKPOh4v
zloBVhuHx0/OC9FRYEM2oWof09pTqCgZ7yzktE7zkU5wmpAAQm9Wp4bUaI51g/8X
f52cm8jyqE0wJT6XWWsfI1Gl28xBP5JOgn9PvJvVBaSk6uxp0aIjOgI6judKf+q7
Az5VCgf4nT20URjjqrGKAxhf+U6wWnFM6lSdZ9xD/IApPVuNyd7OepabqdocURqY
c/y1JbgSZT8=
=xRH5
-----END PGP SIGNATURE-----

--=-zfg8D9pxGIM6OLTwM5ek--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
