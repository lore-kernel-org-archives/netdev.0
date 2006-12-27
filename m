From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211 constants inside d80211_common.h
Date: Wed, 27 Dec 2006 14:12:15 -0500
Message-ID: <200612271412.20125.flamingice@sourmilk.net>
References: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com> <200612271107.45572.flamingice@sourmilk.net> <40f31dec0612270926m6447309do7cbf78b28ee904ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2843169.kDQ7WriiB4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"David Kimdon" <david.kimdon@devicescape.com>,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:56320 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbWL0TM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 14:12:57 -0500
To: "Nick Kossifidis" <mickflemm@gmail.com>
In-Reply-To: <40f31dec0612270926m6447309do7cbf78b28ee904ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2843169.kDQ7WriiB4
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 27 December 2006 12:26, Nick Kossifidis wrote:
> We need those definitions for setting up the rate tables in dadwifi,
> phytypes are needed inside drivers, take a look here ->
> http://madwifi.org/browser/branches/dadwifi-openhal/openhal/ar5xxx.h?rev=
=3D18
>67
>
MODE_IEEE80211A/B/G and IEEE80211_RATE_* not enough? The definitions in=20
d80211_common.h are used for communications with userspace, not drivers. If=
=20
you are using the ieee80211_phytype_* in things that are passed to d80211, =
it=20
is wrong. If you are not, you can switch to MODE_IEEE80211A/B/G and=20
IEEE80211_RATE_*, though I think MODE_IEEE80211A/B/G should be all you need.

> Even if it does get out, constants should be in capitals.
>
Sure. Submit a patch. :)

=2DMichael Wu

--nextPart2843169.kDQ7WriiB4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFksWUT3Oqt9AH4aERAksIAKCTBXtk4tN1s5c4smQTn2YxhPWqnQCfbJI3
cU6Qbe7sePZZNZW3v9yiuYw=
=ZqV8
-----END PGP SIGNATURE-----

--nextPart2843169.kDQ7WriiB4--
