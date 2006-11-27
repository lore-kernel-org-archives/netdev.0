From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED 04/06]: Fix endless loops (part 2): "simple" qdiscs
Date: Mon, 27 Nov 2006 07:46:07 +0100
Message-ID: <20061127064607.GA1625@ff.dom.local>
References: <20061124123350.GA1599@ff.dom.local> <4566EE7C.4090801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:28341 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1757090AbWK0Gje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 01:39:34 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4566EE7C.4090801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 24, 2006 at 02:07:08PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
> > Probably it is as usual something with my eyes but
> > it seems cbq needs in cbq_delete or cbq_destroy_class
> > some treatment (about qdisc_destroy) similar to htb.
> 
> No, you're right about this one, CBQ needs a few further fixes:
> 
> - deactivating of active classes when grafting
> 
> - purging of queue/q.qlen adjustment when deleting an active class
> 
> - deactivating of active classes when q.qlen drops to zero in ->drop()
> 
> - purging of queue and deactivating of active leaf classes
>   when attaching a new child (presuming CBQ can only carry
>   packets in leaf classes, I'm not sure about this)
> 
> and something HTB should do is to turn intermediate classes
> into leaves again when their last child is deleted.
> 
> Are you interested in fixing this? :)

Oops! Sorry, I missed it again!

I've been frightened by the fame of cbq complexity
and I've simply never used it.
But after checking this points look rather trivial
so I've tried.

I'll soon send two patches proposals as separate
threads. The bad thing is I didn't have time to test 
or even learn how to test cbq, so I hope somebody
else would do it.

If any reworking will be needed or patching against
another version, let me know.

If you find it could be usable I'll be glad to do
more things like this. I'll also try to look closer
on cbq.

Regards,

Jarek P.
