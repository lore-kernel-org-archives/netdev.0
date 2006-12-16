From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked list
Date: Sat, 16 Dec 2006 01:40:11 -0500
Message-ID: <200612160140.16446.flamingice@sourmilk.net>
References: <200612141920.11439.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2577606.bZvCAkSvsc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:25067 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030647AbWLPGke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 01:40:34 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612141920.11439.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2577606.bZvCAkSvsc
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 14 December 2006 13:20, Michael Buesch wrote:
> -int ieee80211_update_hw(struct ieee80211_hw *hw)
> +int ieee80211_register_hwmode(struct ieee80211_hw *hw,
> +			      struct ieee80211_hw_mode *mode)
Looks like this function never returns nonzero now. Can it return void=20
instead? This would simplify the fixes for drivers a bit.

=2DMichael Wu

--nextPart2577606.bZvCAkSvsc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFg5TQT3Oqt9AH4aERAiLBAJ956yucHJick57LyBJ6UO4cEOLscQCfXj9C
VSEMQmYdZaIMxCCUd4s5Rxg=
=bHwf
-----END PGP SIGNATURE-----

--nextPart2577606.bZvCAkSvsc--
