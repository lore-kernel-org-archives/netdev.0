From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sat, 11 Sep 2004 16:21:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911142116.GL4431@wotan.suse.de>
References: <20040908065152.GC27886@wotan.suse.de> <E1C4wYe-0005qT-00@gondolin.me.apana.org.au> <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, ak@suse.de,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094823215.1121.129.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 10, 2004 at 09:33:35AM -0400, jamal wrote:
> On Wed, 2004-09-08 at 16:47, David S. Miller wrote:
> 
> > 
> > We are merely moving the sch_generic.c locking logic into the
> > drivers.  The behavior is entirely equivalent except that one
> > level of unnecessary locking has been removed.
> > 
> > I think his change is valid, will not break existing drivers (as
> > you mentioned as well Jamal), and works well for the cases he has
> > shown patches of.  So I'm going to apply his patch.
> > 
> > BTW, if we are really concerned about some existing driver returning
> > -1 from hard_start_xmit() without the new feature flag being enabled,
> > we can test for that and log a debugging message if it happens.

The -1 test is only done when LLTX is set. So even when a existing
driver does that it's fine. Only the drivers that set the new bit
need to be checked.

> 
> I am not 100% happy but let me do some testing on it. Would the best
> image be the latest bk snapshot?

What exactly are you not happy about?


-Andi
