From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted
	to managed
Date: Thu, 04 Oct 2007 20:12:27 +0200
Message-ID: <1191521547.7367.4.camel@johannes.berg>
References: <20071004113343.552139D502B@zog.reactivated.net>
	 <200710041034.48533.flamingice@sourmilk.net>
	 (sfid-20071004_153836_867254_585F0EAA)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-B37ahHA5eiLWXqkayx/E"
Cc: Daniel Drake <dsd@gentoo.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32946 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760528AbXJDSM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 14:12:58 -0400
In-Reply-To: <200710041034.48533.flamingice@sourmilk.net> (sfid-20071004_153836_867254_585F0EAA)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B37ahHA5eiLWXqkayx/E
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-04 at 10:34 -0400, Michael Wu wrote:
> On Thursday 04 October 2007 07:33, Daniel Drake wrote:
> > Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reini=
t.
> > It will then be reinitialised to the default (ieee80211_subif_start_xmi=
t)
> > in ieee80211_if_set_type.
> >
> Well.. this kinda sucks, but we can clean up the logic here later.

I kinda agree, but the hack in 50e1f4d76a9d45c940733f05ccd42c5bbe6ca132
which caused this was is hack too. Somebody really need to rewrite the
whole interface handling, it's a total mess with the master being
specially treated but initialised by the same functions etc. I think we
should start having a IEEE80211_IF_TYPE_MASTER for this, maybe then
things will fall into place nicer.

johannes

--=-B37ahHA5eiLWXqkayx/E
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARwUtCqVg1VMiehFYAQLogRAAh7he12whuR2Qr6dRZwa1zF5T/ZK1UFfR
ulp29b14+krWRBEhZAi568L+2HrzucjCK87k4NB6CrphXddBj83aZp1z8PZSeE47
vsc5QA/RRe+0l0LVJDEPTPh/YI0XCse32FyBJVkaGZ0H1yWO/eYaZ0CnNfF9IBqe
3w2c17ERDbKtu2vSK/PvuoRpz4o50RMB5kgw+AKs6UteqCUZSEzFF8GesVIeucfb
6p2qnLc5i4qJoFxop4oqvxBTQnuTxDwxq0bbo9JLBlQzaQkRYzN3acX1SE5oEEqq
medFtdJ9U2JYZvydL58qQszjg8OoDrfmHHndAhkVudfu4ZvpEs8SuA+KVH+H0lwK
ffTDyMufNlJ/zD8IYnoP9bhx2sqcVs6LZE0zuRN5xrUXi7QB+JxSYZeXDy1K0tEC
KeaUmRgOv3RDTjwqb1RPmblozrms8oe+qffC89lGISmOrK4/LMcmzxAC+fNPbPS8
xC/8pYAJwEfGkKi8aWlEN2kH6OkmMtW/EEETIgg8z4eAw0BthX0skXLMZn7w5jzn
aiq34IW0DSCOwkLmzph5G1tiLzvZB0UZVW7BgRwzrfgmtl4RBpcXXNsDlF+AE611
pHhAfukjKB52WkEQ1gHBUVYg1LG9NZgXIP7sKqL/L0ibRpIFwW7OWKWXiJXbYBn0
x5jFE6wE+kc=
=Q+d2
-----END PGP SIGNATURE-----

--=-B37ahHA5eiLWXqkayx/E--

