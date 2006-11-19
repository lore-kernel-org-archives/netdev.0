From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 17:57:39 +0100
Message-ID: <1163955459.15473.28.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163895673.15473.11.camel@johannes.berg>
	 <20061119155628.GA25061@devicescape.com>
	 <1163954089.15473.16.camel@johannes.berg>
	 <20061119165521.GB25557@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xGYhO+gCf829gXFeLlbs"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:17358 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756786AbWKSQ72
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:59:28 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061119165521.GB25557@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xGYhO+gCf829gXFeLlbs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 08:55 -0800, David Kimdon wrote:

> ok.  I am concerned that making this split between per driver and per
> card is difficult to get right.  Setting or not setting a function
> pointer for an operation is fairly standard practice and I don't see
> the value in introducing yet another way to indicate support.

I guess we can punt this patch until some driver shows up that actually
has some cards that need the function and some that don't. I'm actually
guessing such a driver won't exist but wanted this for completeness in
the split between _wiphy and _ops.

johannes

--=-xGYhO+gCf829gXFeLlbs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYI0D/ETPhpq3jKURAqw5AJ4kKo24/aL9KclfQaST/pAp4eN7cACgqh7a
ngxtz0nClARoFVRaaWWLlBE=
=VMB2
-----END PGP SIGNATURE-----

--=-xGYhO+gCf829gXFeLlbs--

