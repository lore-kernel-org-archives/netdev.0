From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net-2.6.24 rebased
Date: Thu, 30 Aug 2007 13:58:12 +0200
Message-ID: <1188475093.2963.13.camel@johannes.berg>
References: <20070828.175404.23012909.davem@davemloft.net>
	 <20070828.175922.70219802.davem@davemloft.net>
	 <1188430440.6062.110.camel@localhost>
	 <20070829.164130.31655965.davem@davemloft.net>
	 <1188431227.6062.114.camel@localhost> <1188454772.6062.134.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3RKVZpSZ0P3sqEasTDWP"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33589 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517AbXH3L5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 07:57:24 -0400
In-Reply-To: <1188454772.6062.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3RKVZpSZ0P3sqEasTDWP
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-29 at 23:19 -0700, Joe Perches wrote:

> CC      drivers/net/wireless/rtl8187_dev.o
> drivers/net/wireless/rtl8187_dev.c: In function =E2=80=98rtl8187_probe=E2=
=80=99:
> drivers/net/wireless/rtl8187_dev.c:610: error: =E2=80=98IEEE80211_HW_DATA=
_NULLFUNC_ACK=E2=80=99 undeclared (first use in this function)
> drivers/net/wireless/rtl8187_dev.c:610: error: (Each undeclared identifie=
r is reported only once
> drivers/net/wireless/rtl8187_dev.c:610: error: for each function it appea=
rs in.)
> make[3]: *** [drivers/net/wireless/rtl8187_dev.o] Error 1
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Huh? I'm fairly sure I sent a patch to remove it from that driver, no
idea where it got lost. FWIW, you can simply delete the "|
IEEE80211_HW_DATA_NULLFUNC_ACK" part.

johannes

--=-3RKVZpSZ0P3sqEasTDWP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG1rDU/ETPhpq3jKURAs0/AJ9elWuBtLz+DqIon5izn0dMJb8joQCfZh2e
k9Tsak8y2EIdyhsH1evcm1Q=
=hOL0
-----END PGP SIGNATURE-----

--=-3RKVZpSZ0P3sqEasTDWP--

