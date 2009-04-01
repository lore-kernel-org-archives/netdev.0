From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 1 Apr 2009 15:23:40 +0200
Message-ID: <20090401132340.GT11935@one.firstfloor.org>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D35825.3050001@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2009 at 08:03:49AM -0400, Gregory Haskins wrote:
> Andi Kleen wrote:
> > Gregory Haskins <ghaskins@novell.com> writes:
> >
> > What might be useful is if you could expand a bit more on what the high level
> > use cases for this. 
> >
> > Questions that come to mind and that would be good to answer:
> >
> > This seems to be aimed at having multiple VMs talk
> > to each other, but not talk to the rest of the world, correct? 
> > Is that a common use case? 
> >   
> 
> Actually we didn't design specifically for either type of environment. 

But surely you must have some specific use case in mind? Something
that it does better than the various methods that are available
today. Or rather there must be some problem you're trying
to solve. I'm just not sure what that problem exactly is.

> What we *are* trying to address is making an easy way to declare virtual
> resources directly in the kernel so that they can be accessed more
> efficiently.  Contrast that to the way its done today, where the models
> live in, say, qemu userspace.
> 
> So instead of having
> guest->host->qemu::virtio-net->tap->[iptables|bridge], you simply have
> guest->host->[iptables|bridge].  How you make your private network (if

So is the goal more performance or simplicity or what?

> > What would be the use cases for non networking devices?
> >
> > How would the interfaces to the user look like?
> >   
> 
> I am not sure if you are asking about the guests perspective or the
> host-administators perspective.

I was wondering about the host-administrators perspective.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
