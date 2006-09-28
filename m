From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 11:35:13 -0400
Message-ID: <200609281135.24720.flamingice@sourmilk.net>
References: <200609271726.34305.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain> <451BE74F.3010908@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2609213.RG6hEu6Gb4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Michael Buesch <mb@bu3sch.de>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:27377 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1751919AbWI1Pfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:35:53 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <451BE74F.3010908@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2609213.RG6hEu6Gb4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 28 September 2006 11:16, Larry Finger wrote:
> First of all, my problem is quite likely caused by a buggy AP. It is a
> Linksys WRT54G V5, which is one of those with a VxWorks kernel, not Linux.
> I have already reported one bug to Linksys, which they have neither
> acknowledged nor fixed! In that case, SoftMAC had to be modified as a
> work-around.
>
These APs are truly bad. Hacking linux into it (DD-WRT) helps a bit, but=20
wireless often seems to fail *completely* at times.

> I don't know why the deauthentication is being sent. The reason is not
> logged, which will be my first change in the code. The second place to lo=
ok
> is why SoftMAC reports the network is unknown when the MAC printed is that
> of my AP.
>
The deauth reason code is usually 6 or 7.. IIRC, it is 6: Class 2 Frame fro=
m=20
Non Authenticated STA. The AP just forgets you're associated. However, I=20
think that was from when I had a v3 WRT54G.

I made sure the old adm8211 softmac stack had a very good set of printks to=
=20
report these sort of things. :) Many APs do funny things..

=2DMichael Wu

--nextPart2609213.RG6hEu6Gb4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFG+u8T3Oqt9AH4aERAnBAAJ9H3HQMzEjLdK/QCW6cs+kHswEGCQCfeBdZ
OF6ywLrVs1NHaiy7uPxHUfk=
=B3zR
-----END PGP SIGNATURE-----

--nextPart2609213.RG6hEu6Gb4--
