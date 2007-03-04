From: Stephan Maka <stephan@spaceboyz.net>
Subject: Wifi support for iproute2
Date: Sun, 4 Mar 2007 02:26:53 +0100
Message-ID: <20070304012653.GA9587@hooker.hq.c3d2.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([217.160.179.236]:3828 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240AbXCDCBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 21:01:08 -0500
Received: from ip6-localhost ([::1] helo=localhost)
	by spaceboyz.net with esmtp (Exim 4.62)
	(envelope-from <stephan@spaceboyz.net>)
	id 1HNfUZ-0005Do-GB
	for netdev@vger.kernel.org; Sun, 04 Mar 2007 02:26:27 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello

I've always felt uncomfortable by the usability of the wireless-tools
(iwconfig, iwlist), but I really love iproute2. That's why I started to
implement "ip wifi".

My GIT tree is located at:
  http://cthulhu.c3d2.de/~astro/git/iproute2.git/

I wonder if this has a chance to get merged in iproute2 somewhen at all,
or if this is completely inappropriate functionality for this tool.

Note that this my first contribution to a Linux-specific tool, *any*
hints about style and conventions demanded here are welcome.

I'm sure not everyone will use this instead of wireless-tools, and a few
even don't want it compiled in and linked with iwlib. Should I make this
optional through a Makefile variable?

If noone else contributes not all of wireless-tools will be implemented,
it's just too much. But basic stuff for configuring a Wifi card is
already there.

Everyone told me dscape is near, but I hope iwlib will be ported then.


Stephan

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.2 (GNU/Linux)

iD4DBQFF6iBduKMfCHUX8x0RAtF3AJdil/ebCEXA+4xG9jw5jOA4ozouAJ0WdrDy
qy92mEVaTnY29gAeW4akRQ==
=dgIk
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
