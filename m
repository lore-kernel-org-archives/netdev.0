From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Fri, 10 Sep 2004 16:02:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910160209.4f5d8577.davem@davemloft.net>
References: <20040908065152.GC27886@wotan.suse.de>
	<E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	<20040908072408.GI27886@wotan.suse.de>
	<1094629677.1089.155.camel@jzny.localdomain>
	<20040908134713.1bcd46d3.davem@davemloft.net>
	<1094823215.1121.129.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1094823215.1121.129.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 10 Sep 2004 09:33:35 -0400
jamal <hadi@cyberus.ca> wrote:

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
> 
> I am not 100% happy but let me do some testing on it. Would the best
> image be the latest bk snapshot?

Yes, Andi's code plus e1000 and tg3 driver uses are in current
2.6.x BK.  Just grep for NETIF_F_LLTX in drivers/net/tg3.c to
be sure you've got it in your tree.
