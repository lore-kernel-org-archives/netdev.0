From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 21:41:45 +0200
Message-ID: <OF73173D19.3439A8A1-ONC125773F.006BA38C-C125773F.006C31A4@transmode.se>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>	<4C126514.30905@hp.com> <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se> <4C126EC6.9000506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:39705 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760512Ab0FKTn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 15:43:26 -0400
In-Reply-To: <4C126EC6.9000506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> wrote on 2010/06/11 19:13:42:
>
> > The weak model doesn't go into such detail, it is assumption/impl. detail
> > to assume that the ip address still is part of the system even when the interface
> > is down. One could just as well define interface down as temporarly removing
> > the IP address from the system too. This makes make much more sense to me and
> > if you always want the system to answer on a IP adress you make it an IP alias.
> >
> > Since the current behaviour is a problem to me and routers in general, can
> > we change this? What is the current usage model which needs it to stay as is?
>
> Router != end-system  so I wouldn't think the weak or strong end-system model
> would apply to a router.  I think Stephen already posted a patch to allow that
> for when one's box was a router rather than an end-system.

Not really an anwser to what I was asking but I choose to read that as
you agree with me. The rest is an impl. detail. :)
Stephen's patch is good but I would not mind making I/F down removing the
IP address from the system unconditionally.

 Jocke

