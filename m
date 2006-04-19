From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 08/10] bcm43xx: sysfs code cleanup
Date: Thu, 20 Apr 2006 00:30:09 +0200
Message-ID: <200604200030.10218.mb@bu3sch.de>
References: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net> <200604200005.01087.mb@bu3sch.de> <20060419221757.GA29110@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2674630.GUO9ivQP68";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	greg@kroah.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:8885
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751287AbWDSW0I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:26:08 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060419221757.GA29110@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2674630.GUO9ivQP68
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 20 April 2006 00:17, you wrote:
> Michael Buesch <mb@bu3sch.de> :
> [...]
> > the deleted code parses binary input. The
> > new code parses human readable hex input.
>=20
> No offence intended but it was not clear from the description of
> the patch.
>=20
> <pavlov>
> Does it imply an user space visible API change ?
> </pavlov>

Yes it does, but:
* We did not release a stable kernel with it in the meantime.
* There is no software using it at the moment.
  (Well, the bcm43xx-sprom tool is kind of using it,
   but it can handle both binary and hex input anyway)

=2D-=20
Greetings Michael.

--nextPart2674630.GUO9ivQP68
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBERrnylb09HEdWDKgRAiRGAKCnxXXwHYkmD5ZT8xifanMyX2inAgCgpW5Q
FfSQ1vPqX/P8RCGYG214IRI=
=mvcv
-----END PGP SIGNATURE-----

--nextPart2674630.GUO9ivQP68--
