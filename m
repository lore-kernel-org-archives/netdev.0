From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Wed, 09 Jan 2008 15:12:30 +0100
Message-ID: <1199887950.6762.26.camel@johannes.berg>
References: <477FF149.4070609@linux.intel.com>
	 (sfid-20080105_210825_521052_738F2802)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TTKhLXJV/h/4QlCiToUm"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48970 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbYAIOMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 09:12:48 -0500
In-Reply-To: <477FF149.4070609@linux.intel.com> (sfid-20080105_210825_521052_738F2802)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TTKhLXJV/h/4QlCiToUm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Rank 1: __ieee80211_rx
> 	Warning at net/mac80211/rx.c:1672
> 	Reported 6 times (11 total reports)
> 	Same issue that was ranked 2nd last week
> 	Johannes has diagnosed this as a driver bug in the iwlwifi drivers
> 	More info: http://www.kerneloops.org/search.php?search=3D__ieee80211_rx

Note that because we don't get the module list for WARN_ON, we don't
actually know whether all of these instances are from the iwlwifi
drivers. A few other drivers suffer from the same problem. In one of
these cases, iwlwifi was contained in the stack trace, but in the common
case that isn't happening because packet processing is delayed to a
tasklet.

johannes

--=-TTKhLXJV/h/4QlCiToUm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR4TWTKVg1VMiehFYAQKSoxAAggDMC6OMjaonL+Brec/ocoeUSZBWv0th
fbAyM/etIQu+miJLr4CfwyRAk/dNN//Gugrw5L8MmwNuVjVQlI5Gc4UqlT93K424
aZqdpN7PYKFGsWpWW2XsgFd5pdCEGv2WcfEXNEJkHs7aefNnRmLHoQ5/bejMwkMp
rj0n4UHnXELIw1sH3wrJqDksF6+EzgslumsiDULAilryWB3TIHkgqPEnY2vIW0Wq
ywlmq2ep4o9cqCy10ddqjfdE2H1F1Fd8prN5HjJvmVyZruaRtLFr8TT+/hlV3ht/
tT9dKbVbVJanZ+YbhsmBaRo/ODeaoxE5oMu9UxMriXg7+vtitDXr3dIu/ltbdYIq
/X5IniKLcsE6NdbNGC0A+i/sk5yjM+RAhhkzOpgvnMLYVjrDjkyilh3EYx79w0Ik
mpOlJjPnocpkZ7Sx3KdYwZ0n+4dO3VhgKk32MNCvwWtn+Vlyju0yHh5/Z6cyi6oU
56h0YTFpWr7du8ldQtLeuOXc93UR/MKD+R3hr4kWm0qizbbVHAXc2l9c9JkIPlVR
5gFjAA4AW9mthF765tcnCv4LaPJs8cYRhE0yVgsns1Y8iF7h124tHMBX94IDb7zJ
SWXbI4/i/TIsxd8dIvtZXtqgZ5Rj8cqIUgyqRQEmzZtLbX7JTUbk+fif+eWdim3F
OuS66Vjlo9c=
=BLrg
-----END PGP SIGNATURE-----

--=-TTKhLXJV/h/4QlCiToUm--

