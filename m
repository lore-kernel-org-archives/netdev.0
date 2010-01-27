From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Wed, 27 Jan 2010 15:56:16 +0200
Message-ID: <201001271556.16156.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41549 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab0A0N5B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 08:57:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 January 2010 14:36:18 you wrote:
> Unless they are for a different connection? We might have to print sk=
 (%p)
> in all those printouts to be sure which maps to which. If a peer beco=
mes
> unreachable, it may well have multiple connections open (this was a
> proxy, iirc?).
>=20
Ok i will try to do that today.

Most probably different connections, on this proxy i have 10-15k establ=
ished=20
connections at peak time.

Also about estimating rtt, maybe there is something wrong in idea. Just=
 what=20
will happen if ip visible for proxy have multiple people behind? It can=
 be=20
small router for hotspot and 10-20 people behind it,  some with very la=
rge=20
rtt, some with very small.=20

And some of them getting disconnected (out of range from wireless, for=20
example), and thats most probably why host unreachable sent... at same =
time=20
proxy have established and running tcp connections with other people on=
 same=20
router (means for proxy same ip).

Sorry, again to Ilpo J=E4rvinen, by default i have reply, instead of re=
ply all.
