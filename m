From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 20:15:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921181525.GB18938@wotan.suse.de>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org> <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> <20040922.010428.104988024.yoshfuji@linux-ipv6.org> <1095784761.3934.52.camel@tim.rtg.net> <20040921173134.GC12132@wotan.suse.de> <1095789507.3934.69.camel@tim.rtg.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Gardner <timg@tpi.com>
Content-Disposition: inline
In-Reply-To: <1095789507.3934.69.camel@tim.rtg.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 11:58:27AM -0600, Tim Gardner wrote:
> On Tue, 2004-09-21 at 11:31, Andi Kleen wrote:
> 
> > But also allows an easy DOS. Someone just has to spoof a lot of connections
> > attempts with the source address of your primary name server or 
> > some other important service.
> > 
> 
> That is what other iptables rules and filters are for. I get thousands
> of source address spoofs from my Internet connection every day. Network
> security is a layered approach.

I don't think you can eliminate the problem with more filters.
Even when you can eliminate spoofing for some services you use
you cannot eliminate it for all possible services your user
use (unless you get rid of spoofing in the whole internet or you never
talk to any services outside your network) 

And certainly the solution wouldn't work as a Linux default.

-Andi
