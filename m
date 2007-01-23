From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: dscape doesn't auto associate
Date: Tue, 23 Jan 2007 18:43:01 -0500
Message-ID: <200701231843.05902.flamingice@sourmilk.net>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3590790.AkZx8WBcqU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:8277 "EHLO annwn13.rutgers.edu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965601AbXAWXne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 18:43:34 -0500
To: "Jon Smirl" <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3590790.AkZx8WBcqU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 23 January 2007 18:23, Jon Smirl wrote:
> I have to manually associate the dscape stack with my AP. Is this way
> the code is supposed to work? Everything works ok after the manual
> association.
>
It's suppose to work with wpa_supplicant which sets every parameter.=20
NetworkManager uses wpa_supplicant so configuration can be pretty easy.

If you really want to manually associate, set the channel, (e)ssid, and=20
encryption (if any) in any order, and then set the bssid (ap) last. There=20
will be patches to allow association by just setting the SSID for backwards=
=20
compatibility with configuration scripts.

=2DMichael Wu

--nextPart3590790.AkZx8WBcqU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFtp2JT3Oqt9AH4aERAkj7AJ0So5o2kcLZ8/vResUc2+nncW447gCbBEnK
LI6Fu9AyhEdv9ACJRnTSvTE=
=6Wbx
-----END PGP SIGNATURE-----

--nextPart3590790.AkZx8WBcqU--
