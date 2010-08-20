From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re[2]: [PATCH v7] PPTP: PPP over IPv4 (Point-to-Point
 Tunneling Protocol)
Date: Fri, 20 Aug 2010 17:50:59 +0200
Message-ID: <1282319459.2484.249.camel@edumazet-laptop>
References: <1282285499.2295.2.camel@edumazet-laptop>
	 <E1OmTW8-0002E6-00.xeb-mail-ru@f289.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:32922 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab0HTPvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 11:51:04 -0400
Received: by eyg5 with SMTP id 5so2211554eyg.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 08:51:03 -0700 (PDT)
In-Reply-To: <E1OmTW8-0002E6-00.xeb-mail-ru@f289.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 19:28 +0400, Dmitry Kozlov a =C3=A9=
crit :
> > > Ang again...
> > > This patch contains:
> > > 1. pptp driver
> > > 2. gre demultiplexer driver for demultiplexing gre packets with d=
ifferent gre version
> > > so ip_gre and pptp may coexists
> > > 3. ip_gre modification
> > > 4. other stuff
> > >=20
> > > Changes from v6:
> > > 1. memory allocation moved to begin of module initialization
> > > 2. fixed coding style issues
> > > Thanks to Eric Dumazet.
> > >=20
> > > --
> > >  MAINTAINERS              |   14 +
> > >  drivers/net/Kconfig      |   11 +
> > >  drivers/net/Makefile     |    1 +
> > >  drivers/net/pptp.c       |  726 ++++++++++++++++++++++++++++++++=
++++++++++++++
> > >  include/linux/if_pppox.h |   59 +++--
> > >  include/net/gre.h        |   18 ++
> > >  net/ipv4/Kconfig         |    7 +
> > >  net/ipv4/Makefile        |    1 +
> > >  net/ipv4/gre.c           |  151 ++++++++++
> > >  net/ipv4/ip_gre.c        |   14 +-
> > >  10 files changed, 975 insertions(+), 27 deletions(-)
> >=20
> >=20
> > Seems fine to me, but you need to make a nice looking Changelog and=
 add
> > your "Signed-off-by: ...." signature.
> >=20
> > Thanks
>=20
> What do you mean, Changelog of patch ?

I mean the head of your patch that read :
-----------------------------------------------------------------
Ang again...
This patch contains:
1. pptp driver
2. gre demultiplexer driver for demultiplexing gre packets with
different gre version
so ip_gre and pptp may coexists
3. ip_gre modification
4. other stuff

Changes from v6:
1. memory allocation moved to begin of module initialization
2. fixed coding style issues
Thanks to Eric Dumazet.
-------------------------------------------------------------------

This is not a very good Changelog for the final code inclusion in
Linux :). You spent a lot of time in preparing these patches, you can
polish the text so that casual reader have an idea of what you did...

'Ang again...' ?

Dont include "changes from v6" or include all changes (v2,v3, ...)

Of course, once I reviewed your final version, I'll add my signature,
and other netdev developpers (including David S. Miller) might find
other problems that I missed, so what I called 'final code' might be a
not so final...

Thanks


