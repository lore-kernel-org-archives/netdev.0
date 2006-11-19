From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 18:54:45 +0100
Message-ID: <1163958886.15473.31.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163895673.15473.11.camel@johannes.berg>
	 <20061119155628.GA25061@devicescape.com>
	 <1163954089.15473.16.camel@johannes.berg>
	 <20061119165521.GB25557@devicescape.com>
	 <1163955459.15473.28.camel@johannes.berg>
	 <20061119172528.GA26466@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sIB5QWCLBwwZ67CkLCtK"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:25003 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932502AbWKSR4h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 12:56:37 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061119172528.GA26466@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sIB5QWCLBwwZ67CkLCtK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 09:25 -0800, David Kimdon wrote:

> Perhaps that is a split that we do not need?  I don't see the problem
> that 'd80211: split ieee80211_hw' is solving.  I do see what it is
> doing, but maybe I am missing something . . . =20

Oh, I just figured that on 64-bit systems the _ops part is something
like 264 bytes that we needlessly allocate for every device when in
reality it doesn't really change between cards for a single driver.

johannes

--=-sIB5QWCLBwwZ67CkLCtK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYJpl/ETPhpq3jKURAg9GAJ4h50nciXLYbazMDw9vAk9FdaquMQCeKktL
I8zzCj+Uvl4kqul+S8mphKs=
=Sfla
-----END PGP SIGNATURE-----

--=-sIB5QWCLBwwZ67CkLCtK--

