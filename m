From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 3/3] d80211-p54: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 11:33:48 -0500
Message-ID: <200702031133.52203.flamingice@sourmilk.net>
References: <200702031725.22885.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart34431244.cYHmxMeIqE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:43204 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1946493AbXBCQeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:34:23 -0500
In-Reply-To: <200702031725.22885.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart34431244.cYHmxMeIqE
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 03 February 2007 11:25, Ivo van Doorn wrote:
> p54 seems to ignore the beacon that is being passed,
> even though it is requesting the BEACON_TEMPLATE.
> That is why I not only added a line to free the control structure
> but also the beacon itself.
>
Yeah, beacons aren't actually handled yet. BEACON_TEMPLATE can just be turn=
ed=20
off for now if it's causing problems, though I don't see a reason why a=20
beacon would be generated for managed mode.

=2DMichael Wu

--nextPart34431244.cYHmxMeIqE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFxLlwT3Oqt9AH4aERAj22AJ9hAfvcY4Ry55BCCnD+6+YzZ09lFgCfS/WL
B6OTZ0rKCfbzJYaFch8Ooo0=
=z6wB
-----END PGP SIGNATURE-----

--nextPart34431244.cYHmxMeIqE--
