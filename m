From: Andi Kleen <ak@suse.de>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Thu, 30 Sep 2004 00:09:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929220926.GE26714@wotan.suse.de>
References: <20040928214722.11aef8e0.davem@davemloft.net> <16730.53965.503605.943263@robur.slu.se> <20040929125359.12a00ba7.davem@davemloft.net> <1096492842.2344.57.camel@localhost.localdomain> <20040929142750.27b35952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Blake <slblake@petri-meat.com>, Robert.Olsson@data.slu.se,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929142750.27b35952.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 02:27:50PM -0700, David S. Miller wrote:
> On Wed, 29 Sep 2004 17:20:43 -0400
> Steven Blake <slblake@petri-meat.com> wrote:
> 
> > > It can also
> > > be the case that the longest matching prefix entry has no matching
> > > TOS key, whereas a shorter prefix does.
> > 
> > No routing protocols are distributing TOS-specific routes, and there is
> > no prospect of that feature ever coming back.  Why pay the cost of
> > matching TOS on every packet forwarded?
> 
> Because once we add functionality to the kernel we can't simply
> rip it out.  People do use TOS routing, via static routes or
> similar.

I'm not so sure anybody uses it really. How about adding a printk for it 
and seeing if anybody complains? 

-Andi
