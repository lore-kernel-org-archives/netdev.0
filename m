From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 22:33:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008203306.GB15611@oldwotan.suse.de>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com> <20031008202248.GA15611@oldwotan.suse.de> <20031008132402.64984528.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, modica@sgi.com, johnip@sgi.com,
        netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008132402.64984528.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > The suballocation would need to be per CPU to be SMP efficient I guess,
> > which would complicate it.
> 
> Andi, stop right there, we're talking about mitigating the horrible
> performance some $6.00 USD Taiwaneese network cards get on expensive
> ia64 systems.  How much effort do you think we should drain into
> optimizing this? :-)

Well, this thread was about the tigon3 and I don't see that as an el cheapo
card. If SGI uses it on the Altix I guess they want it to perform well 
with many CPUs.

Anyways, it was just a brain dump regarding your idea. I personally
think it's better to just use slab to implement it, allocating pages
doesn't seem to have any advantages to me.

-Andi
