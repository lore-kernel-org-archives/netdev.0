From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 10 May 2010 10:46:00 -0700
Message-ID: <OF13BEB29A.FE5BAFD2-ON8825771F.0060D8AA-8825771F.006196FE@us.ibm.com>
References: <20100510172557.GD28798@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:55307 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab0EJRqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 13:46:19 -0400
In-Reply-To: <20100510172557.GD28798@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/10/2010 10:25:57 AM:

> On Mon, May 10, 2010 at 10:09:03AM -0700, David Stevens wrote:
> > Since "datalen" carries the difference and will be negative by that 
amount
> > from the original loop, what about just adding something like:
> > 
> >         }
> >         if (headcount)
> >                 heads[headcount-1].len += datalen;
> > [and really, headcount >0 since datalen > 0, so just:
> > 
> >         heads[headcount-1].len += datalen;
> > 
> >                                                 +-DLS
> 
> This works too, just does more checks and comparisons.
> I am still surprised that you were unable to reproduce the problem.
> 

I'm sure it happened, and probably had a performance
penalty on my systems too, but not as much as yours.
I didn't see any obvious performance difference running
with the patch, though; not sure why. I'll instrument to
see how often it's happening, I think.
        But fixed now, good catch!

                                                        +-DLS

