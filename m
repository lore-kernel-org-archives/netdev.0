From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: how to listen() on single IP address but very many ports?
Date: Sun, 20 Feb 2011 20:20:07 +0100
Message-ID: <1298229607.8559.61.camel@edumazet-laptop>
References: <4D5EB2AE.5050703@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50378 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256Ab1BTTUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:20:16 -0500
Received: by bwz15 with SMTP id 15so552587bwz.19
        for <netdev@vger.kernel.org>; Sun, 20 Feb 2011 11:20:15 -0800 (PST)
In-Reply-To: <4D5EB2AE.5050703@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 11:55 -0600, Chris Friesen a =C3=
=A9crit :
> I have an application team that needs to listen() for tcp connections=
 on
> many ports (and by many I mean pretty much all 64K ports).  However, =
the
> connections are short-lived, and the number of active connections at =
any
> given time is small.
>=20
> Apparently when they tried this before on an older kernel the
> performance of the naive "open 60K sockets and call listen()" solutio=
n
> was not acceptable, so they used NAT with port mapping to direct all =
the
> incoming packets to a single real port.  However, they now want to ad=
d
> support for IPv6 and this solution won't work.
>=20
> What's the recommended method for efficiently listening on this many
> ports?  Should I be able to efficiently listen() on that many sockets
> using epoll or similar?  If there isn't a way to do this, is there an
> equivalent IPv6 workaround?
>=20
> One possible solution that came up was to implement a PORT_ANY which
> would match any incoming request that didn't already have an explicit
> listener.  Even better would be a way to bind a single listening sock=
et
> to a range of ports.
>=20
> Has anyone ever considered something like this?
>=20

I really dont see how listening to 60K sockets can be "not acceptable".

It just runs OK, at exactly same speed than 1 socket, if using epoll.

Only 'problem' could be memory usage, a bit more heavy of course, but
who cares ?



