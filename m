From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] fix cfg80211 WE compat code
Date: Fri, 22 Dec 2006 12:04:45 +0100
Message-ID: <1166785486.6916.26.camel@johannes.berg>
References: <1165654123.2816.29.camel@portland.localdomain>
	 <20061209160640.GA3365@tuxdriver.com>
	 <87hcw49rg8.fsf@briny.internal.ondioline.org>
	 <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
	 <1165756653.3131.1.camel@johannes.berg>
	 <20061210110802.kq50mvc4s00s0skw@webmail.spamcop.net>
	 <1165767697.3131.29.camel@johannes.berg>  <1166756032.2262.10.camel@dv>
	 <1166765446.8216.3.camel@dv>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-R50lg1YEbU8R6UIF7Lr9"
Cc: Paul Collins <paul@briny.ondioline.org>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41489 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946036AbWLVLFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 06:05:14 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1166765446.8216.3.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-R50lg1YEbU8R6UIF7Lr9
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-12-22 at 00:30 -0500, Pavel Roskin wrote:

> Actually, iwpriv without arguments is still hosed.  In this case,
> cfg80211_wext_ioctl() returns -EOPNOTSUPP.

Ahrg, right, probably caused by me ripping out large chunks of code of
of the base function after copying it as the cfg80211 compat code...
I'll have to take a look.

> I also noticed that cfg80211_wext_ioctl() sometimes returns 0 although
> no drivers I'm using are cfg80211 capable.

Now that really shouldn't happen.

johannes

--=-R50lg1YEbU8R6UIF7Lr9
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFi7vN/ETPhpq3jKURAiXbAKCtBBXB12dr5DR12h8jsnoMUTyRqQCcC3s8
bbHpuyKsaAQRxwWHLWg0hN8=
=TNfU
-----END PGP SIGNATURE-----

--=-R50lg1YEbU8R6UIF7Lr9--

