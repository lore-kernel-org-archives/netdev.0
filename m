From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Thu, 04 May 2006 14:22:20 +0200
Message-ID: <1146745340.1137.26.camel@localhost>
References: <200605032105.53694.mb@bu3sch.de>
	 <20060504111140.050c3e2f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-L1L7ahjs9daoQyEgi8g8"
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37608 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932085AbWEDMWl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 08:22:41 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060504111140.050c3e2f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-L1L7ahjs9daoQyEgi8g8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-05-04 at 11:11 +0200, Jiri Benc wrote:

> I think some safety fallback would be better. Like
> if (stop - start < SOME_MIN_VALUE) channel_change_time =3D SOME_MIN_VALUE
> (of course, this won't work because stop and start are unsigned, but you
> probably got the idea).

Probably. And yes, it should still work since stop>start at all times.

> And couldn't TSF counter overflow during the measurement?

Yes, if the card has been up for like 459148 years or has been reset to
an unbelievably high value. Remember, it's a 64 bit counter.

johannes

--=-L1L7ahjs9daoQyEgi8g8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFnx+qVg1VMiehFYAQK4GA//Ze18XuoNnYALIEBy9NdCN+t8Eor2VXPf
AN+lT995NZFyP4XqP8t216lZlezajssqiFcNSv3B7wrC/o+pLCHJVw50kPsuHEYp
14jKStd6aXClfjXcTGeiEHvj1GU3WYAbk4IHF0wsnYTwzSc5lY0ghr+3RQE51fjf
Ey/2Jigir4inHQNmTOIVOgL1VfAELw16CYUs2uXjOHv/TnS1MuG6AmrWAz58HjnC
25FKb8EmCPzs7rLi/lq5DPaQ4aZOGpxH4L6yn9HZZhxrRVK3ExQ4NJtJDZnkYLeF
+sba50K7zQQ2HnLYkRuZvuQwbFE18rYjZhusZAPLFZRw+ev72yDmyDAtR1jkGOo9
meE+ZfBi6KB22mplYrnL01v/mUJmnLLsxlt6WmFcI9UTK3UP4qdyvVQ/pptG/R1/
A3hxtC11kxp9JKw01yj5/a4PRxHFh7H2yqeUTkMZlZLGBjZFB3XGlIZ9L8oKXPVL
lTaMzAlyJSiPcm/DZ4qvNgG/VDXI0Fr4EdDIMdNZvabUHZJ2S49ezLXg4pwcJos8
qM0cFY4KMjqBq7KKUKRsqkgT7fWIrNzpG/AzWHz1GeBoJNbR4j24ZKNPNcJUJ6w5
p/l496lZNPHt2htCGM7nixvx8oGM1CpQDLkDW/M7ZKznGonsf41TrSeaOsnPMZJ7
jYsrwl6YxTg=
=880k
-----END PGP SIGNATURE-----

--=-L1L7ahjs9daoQyEgi8g8--

