From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Wed, 11 Mar 2009 20:30:59 -0400
Message-ID: <20090312003059.GA12554@localhost.localdomain>
References: <20090303170307.GD1480@hmsreliant.think-freely.org> <20090305210105.GC12835@hmsreliant.think-freely.org> <20090311.091830.152269823.davem@davemloft.net> <49B7E827.3070203@cosmosbay.com> <20090311170701.GA17005@hmsreliant.think-freely.org> <20090311213902.GA18878@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46012 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbZCLAbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 20:31:20 -0400
Content-Disposition: inline
In-Reply-To: <20090311213902.GA18878@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:39:02AM +0300, Evgeniy Polyakov wrote:
> On Wed, Mar 11, 2009 at 01:07:01PM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> > > I was wondering if packets droped at NIC level are handled by "Network Drop Monitor".
> > > (See recent discussion about Multicast packet loss)
> > > 
> > > I believe not, maybe I missed something ...
> > > 
> > No, unfortunately, theres no really good way to detect drops at the driver level
> > without polling them periodically, which I think is somewhat in opposition to the
> > point of this utility.  I'd welcome suggestions however.
> 
> It could be possible to check softnet stats difference when napi is
> scheduled or drop monitor is about to send a packet to the userspace
> about different drop.
> 
Those are both good ideas.  I think I like the former suggestion, since the
latter requires that a drop in the stack must occur to detect a stack closer to
the hardware.  Thank you, I'll keep that in mind for a subsequent enhancement.

Regards
Neil

> -- 
> 	Evgeniy Polyakov
> 
