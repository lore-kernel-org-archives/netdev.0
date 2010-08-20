From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re[2]=3A_[PATCH_v7]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Fri, 20 Aug 2010 19:28:28 +0400
Message-ID: <E1OmTW8-0002E6-00.xeb-mail-ru@f289.mail.ru>
References: <1282285499.2295.2.camel@edumazet-laptop>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f289.mail.ru ([217.69.129.62]:42144 "EHLO f289.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248Ab0HTP2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 11:28:32 -0400
In-Reply-To: <1282285499.2295.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Ang again...
> > This patch contains:
> > 1. pptp driver
> > 2. gre demultiplexer driver for demultiplexing gre packets with different gre version
> > so ip_gre and pptp may coexists
> > 3. ip_gre modification
> > 4. other stuff
> > 
> > Changes from v6:
> > 1. memory allocation moved to begin of module initialization
> > 2. fixed coding style issues
> > Thanks to Eric Dumazet.
> > 
> > --
> >  MAINTAINERS              |   14 +
> >  drivers/net/Kconfig      |   11 +
> >  drivers/net/Makefile     |    1 +
> >  drivers/net/pptp.c       |  726 ++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/if_pppox.h |   59 +++--
> >  include/net/gre.h        |   18 ++
> >  net/ipv4/Kconfig         |    7 +
> >  net/ipv4/Makefile        |    1 +
> >  net/ipv4/gre.c           |  151 ++++++++++
> >  net/ipv4/ip_gre.c        |   14 +-
> >  10 files changed, 975 insertions(+), 27 deletions(-)
> 
> 
> Seems fine to me, but you need to make a nice looking Changelog and add
> your "Signed-off-by: ...." signature.
> 
> Thanks

What do you mean, Changelog of patch ?
