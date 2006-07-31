From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Mon, 31 Jul 2006 13:51:31 -0700
Message-ID: <200607311351.35757.flamingice@sourmilk.net>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1990480.2MiNRIigYL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:47253 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1030357AbWGaUvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 16:51:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060731203113.GG10138@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1990480.2MiNRIigYL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 31 July 2006 13:31, John W. Linville wrote:
> As usual I'll depend on Jiri to merge d80211 stack patches, then
> send me a pull request.  If I apply your "Switch drivers to d80211"
> series now, that will undoutedly cause a breakage when Jiri asks me
> to pull this later.
>
Yeah, there needs to be a new (and smaller) set of patches to switch driver=
s=20
to the d80211.h header.

> I presume that at least parts of those patches will still be necessary
> or desirable after the d80211 symbol rename gets merged.  Are you
> preparing a new patch series for when that happens?
>
I'm not quite sure whether switching d80211_mgmt.h will be worthwhile. If i=
t=20
isn't, then I can get to preparing a new patch series. At any rate, I think=
=20
the most important thing right now is fixing the conflicts w/ wireless-dev =
in=20
the patch that updates the d80211 drivers to use the new names so we can ge=
t=20
the rename stuff into wireless-dev.

=2DMichael Wu

--nextPart1990480.2MiNRIigYL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEzm1XT3Oqt9AH4aERArFNAJ9lTBq5VlXhHE6E+cSMA6lK9KWGwACgs4uB
Esv3O1bTrmGyqH4k1Loudgg=
=yqwg
-----END PGP SIGNATURE-----

--nextPart1990480.2MiNRIigYL--
