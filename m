From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Wed, 30 Aug 2006 10:22:43 -0700
Message-ID: <200608301022.48549.flamingice@sourmilk.net>
References: <44F356DF.9000000@linux.intel.com> <200608291601.56901.flamingice@sourmilk.net> <1156945303.2725.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5906429.AOqZueGMrk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Mohamed Abbas <mabbas@linux.intel.com>,
	Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:60590 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751183AbWH3RXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:23:12 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1156945303.2725.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5906429.AOqZueGMrk
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 30 August 2006 06:41, Dan Williams wrote:
> Um, that's how it's supposed to work, and that's how it's always worked.
> If you're associated with an access point, its BSSID is returned from
> SIOCGIWAP.  If you are not associated, 00:00:00:00:00:00 is returned.
> Please don't break that.
It's already broken in d80211, AFAICT. That's why I replied to myself, afte=
r=20
checking how the implementation actually works.

=2DMichael Wu

--nextPart5906429.AOqZueGMrk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE9cloT3Oqt9AH4aERAmcEAJ42fshOuLTMlfyUhNWWwyXlgLvKHgCgip57
hohx8Hw6SlrvAM5OWd7haKQ=
=KqgV
-----END PGP SIGNATURE-----

--nextPart5906429.AOqZueGMrk--
