From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 12:01:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405221159090.8647@dtop>
References: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>  <CAADnVQ+bvNGhrEqC3P3DqApjcXM3OUUHqTWJ+iwVmC3f4PguEw@mail.gmail.com>  <alpine.DEB.2.02.1405221111190.8647@dtop> <1400782889.5367.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	roy.qing.li@gmail.com, "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:39631 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbaEVTBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 15:01:41 -0400
In-Reply-To: <1400782889.5367.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2014, Eric Dumazet wrote:

> On Thu, 2014-05-22 at 11:13 -0700, dormando wrote:
>
> > CONFIG_IP_ROUTE_CLASSID=y
> >
> > There're a lot of negatives in that description, but if this patch only
> > affects you if CONFIG_IP_ROUTE_CLASSID=n?
>
> Yep
>
>
> Have you tried Linus fix for pipes ?
> (commit b0d8d2292160bb63de1972361ebed100c64b5b37 )
>
>
>

Nope. `git describe` says that's a 3.13 change. I saw that 3.14 is getting
the LTS treatment, so I'm going to rebase our patchset and try to get that
in testing.

I don't think the pipe fix would get all of our bugs though, maybe the
kmem one. Which would be nice.
