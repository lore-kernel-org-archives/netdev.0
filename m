From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 4/5] d80211: Switch d80211 to IEEE80211_ style names
Date: Fri, 4 Aug 2006 15:10:32 -0700
Message-ID: <200608041510.38765.flamingice@sourmilk.net>
References: <20060801211530.150852000.midnight@suse.cz> <20060801191659.59FED483A8@silver.suse.cz> <20060804192040.GA10764@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2481535.OM5fTdjieC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:16519 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1161525AbWHDWKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 18:10:55 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060804192040.GA10764@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2481535.OM5fTdjieC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 04 August 2006 12:20, Jouni Malinen wrote:
> On Tue, Aug 01, 2006 at 09:16:59PM +0200, Jiri Benc wrote:
> This kind of change is more than just search-and-replace since frame
> type and subtype macros were using different style (not shifted left in
> WLAN_FC_{TYPE,STYPE}_* and shifted left in IEEE80211_{FTYPE,STYPE}_*.
> Some of these seemed to be caught in the patch, but not all. At least
> the following changes look incorrect. I'm not sure whether this is a
> complete list of issues, though, so going through all IEEE80211_STYPE_*
> and IEEE80211_FTYPE_* cases again could be a worthwhile exercise.
>
Thanks for the heads up. I tried to make sure everything using=20
IEEE80211_[FS]TYPE_* was correct, but I'm not very familiar with the QoS=20
stuff, so those got through. I'll patch up the QoS problems tonight and loo=
k=20
through any other problem areas.

=2DMichael Wu

--nextPart2481535.OM5fTdjieC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE08XeT3Oqt9AH4aERAu8iAJ9Q9Lm9gDSzTIN2Dke6xkYfckocCgCfX9Wm
PSeNlG3kJggKxzJBWMW/UQw=
=8+E9
-----END PGP SIGNATURE-----

--nextPart2481535.OM5fTdjieC--
