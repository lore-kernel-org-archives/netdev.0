From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Tue, 29 Aug 2006 16:01:49 -0700
Message-ID: <200608291601.56901.flamingice@sourmilk.net>
References: <44F356DF.9000000@linux.intel.com> <44F4BF9E.4040309@linux.intel.com> <200608291550.30203.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7057832.A6cuEISMlE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:41378 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S965155AbWH2XCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 19:02:06 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <200608291550.30203.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7057832.A6cuEISMlE
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 29 August 2006 15:50, Michael Wu wrote:
> On Tuesday 29 August 2006 15:28, Mohamed Abbas wrote:
> >  SIOCGIWAP will always report the bssid no
> > matter what the status of our link.
>
> That is not the case at the moment. Were you planning to change that?
>
Opps, it looks like it is the case. Ignore that.

Perhaps we should make SIOCGIWAP always reflect the AP we're currently=20
associated to, and 00:00:00:00:00:00 if there is none.

=2DMichael Wu

--nextPart7057832.A6cuEISMlE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE9MdkT3Oqt9AH4aERAkm+AKCSKAyNP4ImdgDGY672AMnFmL0n4wCffioA
ttIz8mNcVdSfjxnXLDqDGi4=
=sWDD
-----END PGP SIGNATURE-----

--nextPart7057832.A6cuEISMlE--
