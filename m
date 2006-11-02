From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 0/6] rework d80211 cookie pointer
Date: Thu, 2 Nov 2006 18:28:03 -0500
Message-ID: <200611021828.08294.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1484472.ITYqdfUM2s";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:44928 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1752806AbWKBX2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 18:28:15 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20061102223854.692274000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1484472.ITYqdfUM2s
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 17:38, Johannes Berg wrote:
> Now, I tried to update adm8211 and rt2x00 as well, but faced some
> problems. adm8211 actually accesses the struct net_device and
> calls it's open() call! This is broken.
>
Good catch. Looks like I never updated the suspend/resume code properly whe=
n I=20
ported to d80211. The fix is easy - the code just needs to call the=20
adm8211_open/stop functions directly. I'll send a patch later tonight.

=2DMichael Wu

--nextPart1484472.ITYqdfUM2s
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFSn8IT3Oqt9AH4aERAm4iAKChzelpNcWHHDCY2vURJtnoTZYifgCeND0i
txYHphUZBC7H82CDu3IM09c=
=zSPw
-----END PGP SIGNATURE-----

--nextPart1484472.ITYqdfUM2s--
