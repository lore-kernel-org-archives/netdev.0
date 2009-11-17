From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 23:45:22 +0100
Message-ID: <1258497922.30511.1.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <1258490898.21197.42.camel@johannes.local>
	 <20091117144239.47930866@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-vtYkaYWN1+BwAnPo/pR3"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33054 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756268AbZKQWpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:45:47 -0500
In-Reply-To: <20091117144239.47930866@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vtYkaYWN1+BwAnPo/pR3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-17 at 14:42 -0800, Stephen Hemminger wrote:

> > Felix has recently added a four-address mode to the AP
> > and client side that can be used (after negotiating that
> > it is possible, which must happen out-of-band by setting
> > up both sides) for bridging, so allow that case.

> Looks good, maybe true four-address mode support will be available
> more widely, and this will no longer be an issue.

Doubt it, it breaks the current 802.11 standard, and I think 802.1X too
if you use WPA/RSN. Anyway, thanks.

I'll take a look tomorrow if we can do this generically in cfg80211, and
then send a [PATCH] either way.

johannes

--=-vtYkaYWN1+BwAnPo/pR3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAyd/AAoJEODzc/N7+QmaS6UQAJv/vzcZcwW0LNfaAv3ATF0K
AoW5ysL5qEJ1w1KTmur47NQiRgSjxBiSNkCFvRdvFsiqH3yBw6gTqQ54OSwbxUAW
/cmV6pCC6IQPsb44BTPYLlcE7vX/lRF0CyHvkEZLnoyHmwmjE5fBECq3zKGegNET
ajswyZpt3bcf2KI+3Vq9L3WavH/347LeFMeyVcedACvtO4gfceTmfIpdaHws7emn
8HlB8YlfPQROvgWwnF73pt8VgDLr5WEFh3h187Mpkwm5O168WKGD0kGqYZmcG4lM
+pXBkEILVstkbL3sxeXTwzj6txNFWe8wMPym4WNT40jJ1vlwSeY51hOZ5sKnk6vr
or7TyB83t11L/igazDj27PtJB8gVMdnvjPHnJ5nrLAdhhiL6dfDDa7uTK3+FrMDe
uAvbC/J1p+5kYu3ziPOdsq86YkutMr3F6N4hMLIDScvxEYkdr6Scm6I2tGlSqmdB
QR7fvrMYWQXEMujz5ENqvCdiNG3Yu88Sj22bsZ6uyCsPM0hvq9Z+5qFHi3y1rhkG
JFufWr1oUVUZxyGIL5/t7DZ8WTeRaCemygvijnSQd3ppkgBWgWk4IA1x05QRK7yL
U61Px90moizt5MFO9WOLG2enueI5k0UFGhQniP41NiI0ShHj86KCZQdbhD58VDNy
g6v9jU/p1dFZ7gsYFO13
=Mw7M
-----END PGP SIGNATURE-----

--=-vtYkaYWN1+BwAnPo/pR3--

