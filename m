From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re=3A_[PATCH_v8]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Sat, 21 Aug 2010 13:17:53 +0400
Message-ID: <E1OmkD3-0004PV-00.xeb-mail-ru@f159.mail.ru>
References: <1282376963.2636.10.camel@edumazet-laptop>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f159.mail.ru ([217.69.128.111]:47674 "EHLO f159.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab0HUJR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Aug 2010 05:17:57 -0400
In-Reply-To: <1282376963.2636.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > PPP: introduce "pptp" module which implements point-to-point tunneling protocol using pppox framework
> > NET: introduce the "gre" module for demultiplexing GRE packets on version criteria 
> >      (required to pptp and ip_gre may coexists)
> > NET: ip_gre: update to use the "gre" module
> > 
> > Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> > ---
> > This patch introduces then pptp support to the linux kernel which
> > dramatically speeds up pptp vpn connections and decreases cpu usage in
> > comparison of existing user-space implementation (poptop/pptpclient).
> > There is accel-pptp project
> > (https://sourceforge.net/projects/accel-pptp/) to utilize this module,
> > it contains plugin for pppd to use pptp in client-mode and modified
> > pptpd (poptop) to build high-performance pptp NAS.
> > 
> > There was many changes from initial submitted patch, most important
> > are:
> > 1. using rcu instead of read-write locks
> > 2. using static bitmap instead of dynamically allocated
> > 3. using vmalloc for memory allocation instead of BITS_PER_LONG +
> > __get_free_pages
> > 4. fixed many coding style issues
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
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks Dmitry !

What is the next step ?
