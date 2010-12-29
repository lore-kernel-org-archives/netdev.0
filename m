From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: sysctls below net.ipv[46].conf.all not working as expected
Date: Wed, 29 Dec 2010 17:06:07 +0100
Message-ID: <20101229160607.GH14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58289 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349Ab0L2QGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 11:06:09 -0500
Received: from octopus.hi.pengutronix.de ([2001:6f8:1178:2:215:17ff:fe12:23b0])
	by metis.ext.pengutronix.de with esmtp (Exim 4.71)
	(envelope-from <ukl@pengutronix.de>)
	id 1PXyXQ-0008LE-BM
	for netdev@vger.kernel.org; Wed, 29 Dec 2010 17:06:08 +0100
Received: from ukl by octopus.hi.pengutronix.de with local (Exim 4.69)
	(envelope-from <ukl@pengutronix.de>)
	id 1PXyXP-0004W1-TT
	for netdev@vger.kernel.org; Wed, 29 Dec 2010 17:06:07 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I did the following:

	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
	net.ipv6.conf.all.use_tempaddr =3D 0

	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
	net.ipv6.conf.eth0.use_tempaddr =3D 0

	cassiopeia:~# sysctl -w net.ipv6.conf.all.use_tempaddr=3D1
	net.ipv6.conf.all.use_tempaddr =3D 1

	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
	net.ipv6.conf.all.use_tempaddr =3D 1

	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
	net.ipv6.conf.eth0.use_tempaddr =3D 0

Here I would have expected that eth0's use_tempaddr is 1, too.  The
problem is not that this entry isn't writeable:

	cassiopeia:~# sysctl -w net.ipv6.conf.eth0.use_tempaddr=3D1
	net.ipv6.conf.eth0.use_tempaddr =3D 1

	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
	net.ipv6.conf.eth0.use_tempaddr =3D 1

I got the same results when using net.ipv4.conf.all.rp_filter (and
net.ipv4.conf.eth0.rp_filter resp.)

Is this a bug or just my failure to see how conf/all works?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
