From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 08 Jul 2016 16:14:20 +0200
Message-ID: <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577FAFFD.2020306@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35564 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932540AbcGHOOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 10:14:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id k123so7582819wme.2
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 07:14:23 -0700 (PDT)
In-Reply-To: <577FAFFD.2020306@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. A
> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv6 a=
t
> that system.
>=20
> The IPv6 monitoring from my ISP told my that the to be monitored
> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
> ipv4 there was no issue). Restarting the NIC brought back green light=
s
> for the services at the ipv6 ports too.

Hard to tell without knowing DDOS details, but IPv6 lacks some
scalability improvements found in IPv4.

IPv4 no longer has a routing cache, but IPv6 still has one.

Are you sure conntrack is needed at all ?
