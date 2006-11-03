From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 0/6] rework d80211 cookie pointer
Date: Fri, 3 Nov 2006 17:14:06 -0500
Message-ID: <200611031714.55463.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net> <200611031404.32926.flamingice@sourmilk.net> <19467.82.113.121.16.1162580893.squirrel@secure.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart15929488.Ua2nhmjX3D";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org,
	"Ivo van Doorn" <ivdoorn@gmail.com>,
	"John Linville" <linville@tuxdriver.com>,
	"Michael Buesch" <mb@bu3sch.de>, "Hong Liu" <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:19607 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1753492AbWKCWPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 17:15:11 -0500
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <19467.82.113.121.16.1162580893.squirrel@secure.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart15929488.Ua2nhmjX3D
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 03 November 2006 14:08, Johannes Berg wrote:
> Yeah, I thought about that and added that function to get the wiphy index.
> cfg80211 makes the wiphy index an actual identifier that you can use to
> enumerate all devices it has attached etc, so that makes sense. and d80211
> also puts it into sysfs.
>
> Is that good enough?
>
I still prefer obtaining the name of the master interface because well.. al=
l=20
other network drivers prefix their messages with the name of their interfac=
e.

The master interface name should be as good as the wiphy index to enumerate=
=20
attached devices.

=2DMichael Wu

--nextPart15929488.Ua2nhmjX3D
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD4DBQBFS79fT3Oqt9AH4aERAnYJAJICNE3Y9RtBQBcUB4LDFsN4YmbGAJ90V41b
F18qf4AqcMlW5kOBmnlEJA==
=Hx9U
-----END PGP SIGNATURE-----

--nextPart15929488.Ua2nhmjX3D--
