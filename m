From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26 and ipsec
Date: Thu, 17 Jul 2008 22:42:17 +0200
Message-ID: <200807172242.17752.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:37822 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759681AbYGQUmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 16:42:20 -0400
In-Reply-To: <200807171653.59177.wolfgang.walter@stwm.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 July 2008, you wrote:
> Am Mittwoch, 9. Juli 2008 13:06 schrieben Sie:
>=20
> I started testing 2.6.26 but I get a kernel oops, so I switched back =
to
> 2.6.25.11. Here is the output of dmesg (no logging was switched on so=
 I=20
don't
> have the complete oops). But it happened on several of our routers wi=
thin=20
one
> day:
>=20

Here some further information:

* it happened on several routers when a lot of traffic was going over t=
he=20
ipsec-tunnel, always with this oops

* I copied several times about 32MB via ssh to a router without using t=
he=20
ipsec-tunnel (but the same interface) without any problems

* the same was true when the router had to route the traffic and no tun=
nel was=20
involved

* copying over the tunnel made this same router crash

* only routers with padlock seem to have this problem because I didn't =
observe=20
this on any router without it (i.e. athlons K7 or intel quad-core  - an=
d I=20
tried the same things on them).


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
