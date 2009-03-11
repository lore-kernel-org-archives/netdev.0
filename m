From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Wed, 11 Mar 2009 12:49:59 +0100
Message-ID: <1236772199.20266.3.camel@johannes.local>
References: <20090223192659.GB3553@tuxdriver.com>
	 <1235457113.4455.89.camel@johannes.local>
	 <20090224.235510.30497146.davem@davemloft.net>
	 <1235637360.29050.16.camel@johannes.local>
	 <20090226161340.GA4430@tuxdriver.com>
	 <1235698640.4936.6.camel@johannes.local>
	 <43e72e890902261918p47e45b14i7528dd0f40685879@mail.gmail.com>
	 (sfid-20090227_041853_694385_298BD1F3)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jnMYH6G+MhzIszErd/8+"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58541 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbZCKMj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 08:39:58 -0400
In-Reply-To: <43e72e890902261918p47e45b14i7528dd0f40685879@mail.gmail.com> (sfid-20090227_041853_694385_298BD1F3)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jnMYH6G+MhzIszErd/8+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-02-26 at 19:18 -0800, Luis R. Rodriguez wrote:

> >        mutex_lock(&cfg80211_mtx)
> >        ...
> >        rtnl_lock()
> >        ...
> >        rtnl_unlock()
> >        ...
> >        mutex_unlock(&cfg80211_mtx)
> >
> > to
> >
> >        rtnl_lock()
> >        ...
> >        mutex_lock(&cfg80211_mtx)
> >        ...
> >        mutex_unlock(&cfg80211_mtx)
> >        ...
> >        rtnl_unlock()
> >
> > everywhere.
>=20
> Sure, I'll give it a shot tomorrow unless someone else gets to it first.

Did you get a chance to look at this? Otherwise I'll just do it later
today.

johannes

--=-jnMYH6G+MhzIszErd/8+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJt6VkAAoJEKVg1VMiehFYLvEP/A/D27QVo38BoZx2ls0NBiOR
CUHzXIOKnUAMOA1Wx/Qe+X+mK+zjx3PqM5aSa0A/qrfuYBXajm5gFJt9N/OLQY1w
diJ5f7gC+H53ezgZRU8MmFdack6Zpt4qbGBYZDp/MHTtWF/fYYO/AsvuRfOQZMAo
1F5SzyX+u8kVW8Eom2hWV8X+68gVKCNVVsq9FI886ABsXDqYFiQ4mfTV/uQm6ojO
/Uwnry/sS/EkR2wmrBddr5gQ+Cz7n6luVWnA71zgQTld+dho0iq73iuF1odO8ftb
olA+KpS1oT2sQygBUbT/5uAT+KF+gGlSzTpp8LEgqsxyIVfESfUUSUGRBb+tFLFf
ib+jJHCtKQXC3UsBOhe9WntgfCBGpwJcrDQktzz9vmCv+qDXOcbFl2iJwoNj26nc
RRhA9buIY9vSuduSafq3YSHtswAWKul0aw+6mk/sOXndApe+A/Sn4wAgNAMpabhW
K20ZbDhQsxOh4Ay9U7szKnYQx8xW8wOB8WV4eOqcz6cWsXDzMuMnncXkr1JDUMgL
QPeDVEfleg1hesJXVQ8wx15c9ndAyENkjK7gPBvWBFfviJJ3ijBAyaXdvP5xo87u
K7AzHSasaCuMq3uD/tcL+SfSn7LrSEsfuoZpzAorrUMS06nBmjKNXBRw8wErmdj/
cMOmXaRhI/5UMm6Xl+O1
=/o50
-----END PGP SIGNATURE-----

--=-jnMYH6G+MhzIszErd/8+--

