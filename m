From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 08 Jul 2016 16:53:21 +0200
Message-ID: <1467989601.30694.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577FAFFD.2020306@gmx.de>
	 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAOp4FwTgvOP504nmRVejZzqYia2Z=WdGa2Fd7e4TZ0hc7YfHcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev <netdev@vger.kernel.org>
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34349 "EHLO
	mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbcGHOx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 10:53:29 -0400
Received: by mail-qt0-f195.google.com with SMTP id m2so7567508qtd.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 07:53:23 -0700 (PDT)
In-Reply-To: <CAOp4FwTgvOP504nmRVejZzqYia2Z=WdGa2Fd7e4TZ0hc7YfHcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 18:17 +0400, Loganaden Velvindron wrote:
> On Fri, Jul 8, 2016 at 6:14 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
> >> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. =
A
> >> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv=
6 at
> >> that system.
> >>
> >> The IPv6 monitoring from my ISP told my that the to be monitored
> >> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
> >> ipv4 there was no issue). Restarting the NIC brought back green li=
ghts
> >> for the services at the ipv6 ports too.
> >
> > Hard to tell without knowing DDOS details, but IPv6 lacks some
> > scalability improvements found in IPv4.
> >
> > IPv4 no longer has a routing cache, but IPv6 still has one.
> >
>=20
> Any pointers as to which part of the kernel to look for to implement
> one for IPv6 ?

net/ipv6/route.c and net/ipv4/route.c ?
