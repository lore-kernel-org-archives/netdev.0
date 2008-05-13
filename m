From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Tue, 13 May 2008 23:37:23 +0200
Message-ID: <1210714643.4279.27.camel@johannes.berg>
References: <20080502.163334.148944203.davem@davemloft.net>
	 <1209807477.3987.9.camel@johannes.berg>
	 <1209824720.1475.6.camel@johannes.berg>
	 <20080512.201751.114868351.davem@davemloft.net>
	 <20080513203906.GB20269@tuxdriver.com>
	 <1210712356.4279.22.camel@johannes.berg>
	 <1ba2fa240805131412i3bd1756bhb11d31742b326b2f@mail.gmail.com>
	 (sfid-20080513_231212_813726_F80F0C2D)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xjvV9yiNaUz+qM3d/OfK"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54061 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758775AbYEMVic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 17:38:32 -0400
In-Reply-To: <1ba2fa240805131412i3bd1756bhb11d31742b326b2f@mail.gmail.com> (sfid-20080513_231212_813726_F80F0C2D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xjvV9yiNaUz+qM3d/OfK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> >  Most fullmac devices also need some space, whether they do things that
> >  way or not is a completely different thing, the ieee80211 stack for
> >  example copies every packet into a new skb anyway.
>=20
> It's really depends on when is the 802.3 to 802.11 header translation
> made it doesn't matter whether it's fullmac or softmac. I would say
> that WLAN is OK.

True, some devices take 802.3 frames and do the translation and
everything themselves. I dunno. I guess it would make sense to make it
mac80211 anyway because ieee80211 doesn't care and the other drivers are
probably handling this in some other way anyway (if maybe even by using
different dma descriptors, or just not caring because transfer speeds
are low enough)

johannes

--=-xjvV9yiNaUz+qM3d/OfK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCoKEaVg1VMiehFYAQKY/w/9FhWlK2a9A0LBfnYkJ+6BIiEzjJYHxkLT
++SgIkDbZJ8WZk4bEyH69uJQmXNuF5mTCxdg5EysLGPml69+rI7eSkEb9v66skg8
bfyns6kEoW4GsTT3ftJmSKEkGBNW+Q0Vt6tXqk8rFE4ofvrkW0bWkId95CO1lHjf
/7cGLta4FoansqNFFHnsyXXKsGmjfj7K4qtxzxq6aHocy05DRpZi7YMP67joXvtO
zZu773KUXZvp1caZtHqFYH5/GfaQ0aC4dGHeuTzEEIFR05A+mfK1sTOXolTiWXmX
d70U4I+/5C4/gr4ktFSq2kUpsH/R48T29jhlN4KBNOJQnmkTMcc3yZXmdPZXeO8g
6NOvg+IEAIVijnuO+6THukhIBX3s4oxFfKZt0yh06vFxIEEFawWkTQUWnIie0/cs
BW2WmhThCXC1kcFsofpQ1KA6hvFFhcbZB0FUza3+8hlvJXAO4dFE1T8mG0is+aBZ
dwhNjBM7ZaZaleWQWzZrbGORryU63v9UHb/9A/lxGwLMqMj0/6HJdIJsiVbKWS19
8QoSbH10H/KApgFNrMUervCitGZn00NpkBYgFZIo/H+YmT0EOXnDVdW1E4PxsoGZ
omTRqK3vGYkaxkzKGXglUWXD7UxmoVnZ9il3Ow3/RqzHG+OPuu/Zasgg8SFh9X3Y
CNqdEDvv4HA=
=nsD0
-----END PGP SIGNATURE-----

--=-xjvV9yiNaUz+qM3d/OfK--

