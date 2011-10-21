From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: fix ICMP redirect validation
Date: Fri, 21 Oct 2011 16:13:24 -0200
Message-ID: <20111021161324.25916a7c@asterix.rh>
References: <20111017.194344.510280595317217573.davem@davemloft.net>
	<20111019160537.4aeedef8@asterix.rh>
	<20111020154702.13f69021@asterix.rh>
	<20111020.161929.97626808571871075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597Ab1JUSN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 14:13:27 -0400
In-Reply-To: <20111020.161929.97626808571871075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Oct 2011 16:19:29 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Thu, 20 Oct 2011 15:47:02 -0200
> 
> > I was reviewing this again and instead of doing the above, it would
> > be better to use rt_bind_peer() to update rt->peer as well.
> > 
> >                         if (!rt->peer)
> >                                 rt_bind_peer(rt, rt->rt_dst, 1);
> > 
> >                         peer = rt->peer;
> >                         if (peer) {
> >                                 peer->redirect_learned.a4 = new_gw;
> >                                 atomic_inc(&__rt_peer_genid);
> >                         }
> > 
> > 
> > but I am not sure if I understood you completely when you say
> > to do such that only an inetpeer cache probe is necessary.
> 
> If you have the route entry available already and you're doing the
> inetpeer lookup anyways, you might as well use rt_bind_peer() since
> all of the expensive work has to be done anyways.
> 
> So yes, using rt_bind_peer() would be the best thing to do here.
>

just posted patch v3. iirc, you prefer to receive patches as new
posts rather than replies to old threads.
"Subject: [PATCH net-next v3] route: fix ICMP redirect validation"

thanks again,
fbl
