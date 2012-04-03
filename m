From: Jean-Jacques Sarton <jj.sarton@t-online.de>
Subject: set route
Date: Tue, 03 Apr 2012 07:47:37 +0200
Message-ID: <4F7A8EF9.80006@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout04.t-online.de ([194.25.134.18]:54144 "EHLO
	mailout04.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab2DCFrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 01:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello,

I think there is a little bug within the portion of code
for setting the network routing.
If I issue the following

ip li se dev x down; ip li se dev x up;\
ip ad ad 2001:db8:1:1::2/64 dev X;\
ip ro ad 2001:db8:1:1::/64 via 2001:db8:1:1::2 dev X

All id OK. If I insert a sleep 2 between set addr
and set route, I will get the error message:
RTNETLINK answers: No route to host

This seem, for me to be a BUG. The address is known
and therefore there is a route.
If the addresse for the gateway is outside, this
may make sense, but for a static route I expect
that the route is set regardless of the knowledge
of the addresse.

Do you have an explanation for the problem and if
this is a bug, will it be fixed ?

Regards,

Jean-Jacques Sarton
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAk96jvkACgkQM9JbiR3CwQskpACeMj0S6q5IYD9FhwGLOZZjWeKr
A3sAn1s99YK7aacxQ+Eiqb9MI4CaWDs+
=yLUY
-----END PGP SIGNATURE-----
