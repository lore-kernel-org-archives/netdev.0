From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Make MACSTR/MAC2STR macro available to drivers
Date: Sun, 23 Jul 2006 02:31:58 -0700
Message-ID: <200607230232.05302.flamingice@sourmilk.net>
References: <200607230143.31375.flamingice@sourmilk.net> <200607231110.06834.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1460208.spUURQTnGW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:17071 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751174AbWGWJcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 05:32:08 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607231110.06834.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1460208.spUURQTnGW
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 23 July 2006 02:10, Michael Buesch wrote:
> On Sunday 23 July 2006 10:43, Michael Wu wrote:
> > d80211: Make MACSTR/MAC2STR macro available to drivers
> >
> > This patch moves the MACSTR/MAC2STR macros to d80211.h
> > so that they are available to drivers. It also converts the adm8211
> > and bcm43xx drivers to use this macro.
>
> I'd say d80211.h is still the wrong place for this.
But it's less wrong than before. :)

> What about etherdevice.h?
Sure, but I'll have to update many more drivers to make that happen. Using=
=20
macros to print mac addrs seems to be mostly confined to wireless drivers
at this point.

=2DMichael Wu

--nextPart1460208.spUURQTnGW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEw0IVT3Oqt9AH4aERAg8CAJ4gQwtEhbFAsodckjQvyaxdpUezgwCgrp2v
gwR9eAknzpycaBKerJArhDk=
=IwEa
-----END PGP SIGNATURE-----

--nextPart1460208.spUURQTnGW--
