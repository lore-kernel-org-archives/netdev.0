From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: adm8211 (from linville wireless-2.6) in xen guest
Date: Mon, 22 Jan 2007 14:30:45 -0500
Message-ID: <200701221430.50547.flamingice@sourmilk.net>
References: <45B208DA.8010807@caiway.nl>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1936078.Tpcqzj9qqM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:13333 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751959AbXAVTbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 14:31:18 -0500
To: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>
In-Reply-To: <45B208DA.8010807@caiway.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1936078.Tpcqzj9qqM
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 20 January 2007 07:19, Jan Evert van Grootheest wrote:
> Hi,
>
> Just writing to thank all of you that made the adm8211 driver in John
> Linvilles wireless-2.6 development tree (not the dscape one, which I
> will try also).
>
CC me then. :) Note that I only maintain the d80211 based adm8211 driver no=
w,=20
but that driver doesn't have adhoc support yet.

> One question, though. I'm trying to use it in ad-hoc mode. If there's no
> other station with the same essid, it just keeps mentioning that
> (besides the BCNTC and TSFTF messages)
>
> wlan0: No matching adhoc sta found. Creating IBSS 00:04:e2:3f:2a:70 CHAN=
=3D11
>
> And the IBSS changes every time, which is about every 30 seconds. Is it
> really supposed to change the IBSS each time?
Probably not, but I never debugged adhoc mode enough.

> The reason I ask is that my wife has a laptop with an Atheros chip in
> it. If it is configured for ad-hoc it creates the IBSS and sticks with
> it. So I now have two computers that have different behaviour in this
> respect. That in itself is not, I guess, a problem. But it seems to me
> that the random IBSS created by the adm8211 would result in two stations
> not seeing eachother or taking longer than necessary to find eachother?
>
Have you checked? I think the bssid should stop changing once another stati=
on=20
with the same ssid comes into range.

> And one more question that I don't understand... the wlan0 interface
> does not appear in snmp queries. Any idea about that?
>
Nope.

=2DMichael Wu

--nextPart1936078.Tpcqzj9qqM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFtRDqT3Oqt9AH4aERAmEXAKDN0O6zGz5mDT8b5drjsrd8728I8gCfTfVL
O7ulZVditnNLNUatMr5Aa6k=
=+ODs
-----END PGP SIGNATURE-----

--nextPart1936078.Tpcqzj9qqM--
