From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Fri, 03 Nov 2006 01:22:47 +0100
Message-ID: <1162513367.3381.11.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net> >
	  <20061102230013.960383000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3b6uy4Ida8dhir8Tng/W"
Cc: netdev@vger.kernel.org, Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:25220 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752871AbWKCAYO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 19:24:14 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061102230013.960383000@sipsolutions.net>>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3b6uy4Ida8dhir8Tng/W
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 00:09 +0100, Johannes Berg wrote:

>  /* Return a pointer to network statistics data area for the given device=
. */
> -void * ieee80211_dev_stats(struct net_device *dev);
> +void *ieee80211_dev_stats(struct ieee80211_local *ieee80211_ptr);

Ok, that one was wrong. But what is it doing in the public API? We need
to remove it from the public API and leave struct net_device *dev as the
parameter. adm8211 actually uses it and increases the tx_fifo_error
counter, but that's a bit strange.

johannes

--=-3b6uy4Ida8dhir8Tng/W
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUqL1qVg1VMiehFYAQLJVA//YrxFenX4wELLjp/lmLsHjUUCYRL5MIfk
Wj6T9C6GVPEqbHOYiFeO/cAIbDc5Dxk/5u69l98rWim06Y6UBjeBNDrPIzzIRDnt
oqf2xMyuz7c8nEdLNxKzcL7HCogdMxQZeCucazP8qlvC0SuUQ8yZ0OumMkimkCoO
/gdmJcNIUC2OyreLxsUEsQqO/O2LWM+z66HKsi+i/FXDvWNGSvy58fG8egowQQmu
CMfy3OevodSiYI+qgCpxhCUwMuFbIalYM1CbpWReIFrjL47N2Vd7ZNUsOvXv7Uvw
wNmIR+iPExU/TNFMsXX86a+gZHLAfcDtjwaXYM4Q2fzk8p+QjbPlo75PUq4aUqFj
46AIVAcfRNkJvSKLPwo3ztg9sK3CRyZ2A0rRiSjQhfMiF3bSW1AhYO0/LzeXkCdM
r9v+bRlPQUrLNxftaPZLJAKQeJAPvLUM6+oQl4KGD6MjnE7wdtFv8Lpzxe4WUGk0
S9nDnkkK42kRdpZzlxta21m4DkiPfTOfBIqQ4j4Hwn1jRIem6mLAaW2NB26epfWu
7TsgFAe/Vic5aJTov/wW1mUAyJ1IM6i4ths/YZaeH1U+ri8ovzRNJS3vY9QqbpqB
eQrnxuZ7EdSIRmF2yt4iyWV2DYIO6/lC+XpR/0f8edOucjnQTANZ8oktF1mT9sby
/irphEnkoWo=
=aBac
-----END PGP SIGNATURE-----

--=-3b6uy4Ida8dhir8Tng/W--

