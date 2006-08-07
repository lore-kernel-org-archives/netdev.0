From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Switch d80211_mgmt.h to ieee80211.h style definitions
Date: Mon, 7 Aug 2006 11:37:08 -0700
Message-ID: <200608071137.13428.flamingice@sourmilk.net>
References: <200608050145.40137.flamingice@sourmilk.net> <20060807172050.GH4702@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1368796.0FbqjypxPC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:2508 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932295AbWHGSiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 14:38:00 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060807172050.GH4702@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1368796.0FbqjypxPC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 07 August 2006 10:20, Jouni Malinen wrote:
> Changing WLAN_STATUS_* and WLAN_REASON_* to be enum's while keeping
> their old names is fine. However, I would rather not change the names of
> the information element IDs (WLAN_EID_*) into MFIE_TYPE_*. What is that
> 'MFIE' anyway? Management Frame IE? These IEs are not limited to
> management frames..
>
I agree these names aren't that great, but these changes make it easier for=
=20
for existing fullmac drivers to switch to the d80211 headers. That is the=20
only reason.

> In other words, I would skip all the changes into ieee80211_sta.c and
> would only change d80211_mgmt.h to use enum's with old names.
Sure.

=2DMichael Wu

--nextPart1368796.0FbqjypxPC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE14hZT3Oqt9AH4aERAoEZAJ4vhyc2m5Aegcp8sFVMTlhQwta69gCfc7Wp
c1pkFBxki6l0KT0/gtDGVOk=
=lZC9
-----END PGP SIGNATURE-----

--nextPart1368796.0FbqjypxPC--
