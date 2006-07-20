From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] drivers/net/wireless/d80211: Check configuration type in hw->config_interface.
Date: Wed, 19 Jul 2006 18:07:05 -0700
Message-ID: <200607191807.12360.flamingice@sourmilk.net>
References: <44BE958C.4030401@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2858437.xOOTPqW5x0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:13540 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932552AbWGTBV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 21:21:58 -0400
To: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
In-Reply-To: <44BE958C.4030401@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2858437.xOOTPqW5x0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 19 July 2006 13:26, Jean-Mickael Guerin wrote:
> This patch prevents a NULL pointer dereferencing in AP mode:
> ieee80211_if_config will set conf->bssid only if device is of type STA
> or IBSS.
Why is that? Isn't there a BSSID in AP mode too? Perhaps it is calling=20
config_interface before setting the BSSID?

adm8211 doesn't support AP mode yet, but it's good to know this crash won't=
=20
occur when it does. :)

=2DMichael Wu

--nextPart2858437.xOOTPqW5x0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEvtdAT3Oqt9AH4aERAjpGAKCV/ABvSqLuaxrigYhne8f7gUKlzwCgkJy3
yz+wz33Pbgb4TygTpKrY3mE=
=TkIj
-----END PGP SIGNATURE-----

--nextPart2858437.xOOTPqW5x0--
