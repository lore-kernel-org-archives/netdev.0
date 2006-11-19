From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 17:50:39 +0100
Message-ID: <1163955039.15473.26.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163895673.15473.11.camel@johannes.berg>
	 <20061119155628.GA25061@devicescape.com>
	 <1163954089.15473.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WtI22l5F2qMv2v5o8W3P"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:22213 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756778AbWKSQw1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:52:27 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <1163954089.15473.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WtI22l5F2qMv2v5o8W3P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 17:34 +0100, Johannes Berg wrote:

> Well I want to allow drivers to make assign the 33 function pointers in
> a static structure, and differences between cards must then be handled
> in the non-static part.

Uh, that didn't come out too well.

The point is that ieee80211_ops can be static after these changes which
is a whopping 33 function pointers or so :)

And only at the expense of having a few new flags.

johannes

--=-WtI22l5F2qMv2v5o8W3P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYItf/ETPhpq3jKURAtMZAJsGE7b9Zxo6AWtCTykjvpcpw6OO1ACgtqCS
g23oT6gPf9/mzn/1syLpw94=
=m88g
-----END PGP SIGNATURE-----

--=-WtI22l5F2qMv2v5o8W3P--

