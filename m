From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 4 Oct 2007 13:11:33 -0400
Message-ID: <200710041311.37997.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041706.06182.mb@bu3sch.de> <20071004151956.GE6037@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2218133.jPUbnScrFo";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Daniel Drake <dsd@gentoo.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:37880 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753932AbXJDRNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 13:13:32 -0400
In-Reply-To: <20071004151956.GE6037@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2218133.jPUbnScrFo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 04 October 2007 11:19, John W. Linville wrote:
> > The reason why BUG_ON exists is to catch bugs that happen, although
> > they Should Never Happen (tm) ;)
>
> Precisely.
No really, this bug will never happen. This is function is merely a helper=
=20
function which is called from interface removal code (where the interface=20
*has* to be down) or from changing the interface type (which ensures that t=
he=20
interface is down first). There are an unlimited number of bugs which Shoul=
d=20
Never Happen. That doesn't mean we should start adding BUG_ONs for every=20
single one of them. That gives some sort of protection against cosmic rays=
=20
flipping bits, but down here on earth, it's bloat.

=2DMichael Wu

--nextPart2218133.jPUbnScrFo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBR7JT3Oqt9AH4aERApDzAJ9h+BzJpVbrARB5/dWAuxH37jJUSQCZAdXV
204SkDaDFzBkyKDMfMdWL0M=
=zXlt
-----END PGP SIGNATURE-----

--nextPart2218133.jPUbnScrFo--
