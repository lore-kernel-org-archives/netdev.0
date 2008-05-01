From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 12:58:20 +0200
Message-ID: <1209639500.7067.0.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
	 <20080501.035335.216935614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-esTyxMHr2gaQOOnWU6as"
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37534 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690AbYEAK7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:59:13 -0400
In-Reply-To: <20080501.035335.216935614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-esTyxMHr2gaQOOnWU6as
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-01 at 03:53 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 01 May 2008 03:49:50 -0700 (PDT)
>=20
> > I guess it's the pskb_expand_head() calls done by net/mac80211/tx.c
> > I suspect we'll need to orphan early in order to accomodate these
> > adjustments, otherwise socket memory buffer allocations will
> > be corrupted.
>=20
> I think the mac80211 encryption paths on TX could be doing this as
> well, just something I noticed meanwhile.

Indeed. But then why did we never see this bug w/o monitor interfaces
and this reinjection?

johannes

--=-esTyxMHr2gaQOOnWU6as
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmiS6Vg1VMiehFYAQIpIQ//WXatDQJJSe+aqpDwZ9vsNG3qDEByrNGb
ceo636ub1gMSfJ6MnR1PA7Y7qIKwLw7S1FH9dIrn4a2TDa/RuV2h3fDL80OI58ls
LIaZRopKC4irCa48aCfbp/kuSRcMff/gFl4hJjPijzF33D/lX3CKT7opqtn0YArP
qNp7H4PPtUGoWCtMSZCgxQzcisD83erBxIF5BPBmfJclxB0fwW10HWbeg+Xp4k/8
lEoshh9YsfiT0jt7HErpE5Pr0papYIQQ79cDBDTZNPitYj5IwEbYNehAw0JUwTsc
stsf3qOfq4KAZND0RC2tIVjJc46qPsk0MYjKBQsvCPJB3AZArWl/m/YhYNeQNTQl
NZI+SRYNoh6p4uAzOQ7fGmr7duKWiTh35GOSaWKiiHfLi4M/cH2cD+SwCwePyjMI
ScaxGust5Gilm0A/jATYf6sYHlV+2KyrpLOskQupC39wMDSoSNjBx3jwhHMdiphJ
zLEjYUvhEnMDRx1OheYHGkW9qcRFBo/IpkmxGCFreKUCEEx8QmE/QvIikx/6w0Ve
WyDqWXvWpUXOsqVVCZ1j+wKifNOcmPTL/8ikZblXF5lHlX67KPVid2RxUMYK8Y+E
01f15Nlych4YNzbW0kJM78OneKCRa7QoQpRe0B7GkNGxLRWsQv/+/ph6O+ABfvMy
pw1Z+6/rVkQ=
=hoxx
-----END PGP SIGNATURE-----

--=-esTyxMHr2gaQOOnWU6as--

