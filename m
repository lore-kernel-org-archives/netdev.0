From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: 3945 driver using d80211
Date: Wed, 9 Aug 2006 09:47:15 -0700
Message-ID: <200608090947.20291.flamingice@sourmilk.net>
References: <44D901C9.6090304@linux.intel.com> <200608081440.48623.flamingice@sourmilk.net> <44D99558.1000507@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2671336.cfW7sWxpVj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Mohamed Abbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:60633 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751020AbWHIQrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 12:47:23 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44D99558.1000507@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2671336.cfW7sWxpVj
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 09 August 2006 00:57, Johannes Berg wrote:
> Please not, for now. We need someone pushing for fullmac features in
> d80211, we need those anyway for embedded systems that can't afford
> running all of it on the main CPU. While obviously Intel would benefit
> from doing this since a lot more d80211 features would come available,
> the greater good would be having a main-stream card that someone cares
> about and helps making d80211 full-mac capable.
>
It's not that hard to generate probe, authentication, and association frame=
s,=20
and it isn't done frequently enough to stress any embedded system that can=
=20
run linux. Doing this would let 3945 take advantage of all the d80211=20
features, so why not?

What level of fullmac support are we talking about? True fullmac cards (as =
I=20
define them) do not need to use d80211. WE19 is all they need, to add=20
WPA/WPA2 support. The IPW cards have a particularly unique split between=20
firmware and host 802.11 duties which I haven't seen in any other cards. Th=
ey=20
aren't quite fullmac enough to interface with WE directly, yet they only ne=
ed=20
probe response handling to complete the picture. What other half-fullmac,=20
half-softmac card besides the other IPW cards splits card/host 802.11 dutie=
s=20
along those lines? What other splits between card and host are out there? I=
=20
would be very reluctant to make changes to the 802.11 stack to support=20
"fullmac" without evidence that other drivers need the change.

=2DMichael Wu

--nextPart2671336.cfW7sWxpVj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE2hGXT3Oqt9AH4aERAocVAKDZMkF/kOia/gYrwpCuv9pAQUzQAgCgkazZ
+RL1wSIV9yk3HuKSZb+YQeg=
=yUeb
-----END PGP SIGNATURE-----

--nextPart2671336.cfW7sWxpVj--
