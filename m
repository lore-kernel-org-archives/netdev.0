From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [irda-users] Re: [PATCH] (0/16) intro to IRDA patches for
 2.6.0-test6
Date: Wed, 1 Oct 2003 01:25:34 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310010122110.1388-100000@notebook.home.mdiehl.de>
References: <20030930230049.GA22339@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>,
        <irda-users@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>
In-Reply-To: <20030930230049.GA22339@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003, Jean Tourrilhes wrote:

> On Tue, Sep 30, 2003 at 03:25:30PM -0700, Stephen Hemminger wrote:
> > These patches are a replacement for the moderate one chunk I sent out yesterday.
> > They continue in the same vein of revising how IRDA devices are allocated.
> > The new thing is the introduction of alloc_irdadev and changing over the places
> > I used alloc_netdev to that.
> > 
> > Mostly they are trivial, but smsc-ircc2 got changed to get rid of check_region
> > usage as well.
> > 
> > David, please apply after Jean gives his approval.
> 
> 	The self destruct patch is absolutely needed, and I like very
> much the alloc_irdadev work.
> 	Please go ahead, I'll test them in parallel.
> 	Thanks !

I hadn't yet time for testing but since you were asking: I do also like 
the alloc_irdadev/free_netdev approach and the sir_dev part looks good to 
me, i.e. no leaking there. Thanks Stephen!

Martin
