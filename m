From: Andi Kleen <ak@suse.de>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 21:51:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001195146.GA23046@wotan.suse.de>
References: <20040930213221.06a3f5b3.davem@davemloft.net> <20041001121123.19511403.ak@suse.de> <20041001124733.1ac4266a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com, jheffner@psc.edu,
        herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041001124733.1ac4266a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 01, 2004 at 12:47:33PM -0700, David S. Miller wrote:
> On Fri, 1 Oct 2004 12:11:23 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Do you want me to play with the new sysctl too?
> 
> Yes.

Already did, see my other mail (I should not read incoming mail in the wrong order @)
> 
> >      max win adv:            5840 bytes     max win adv:           63712 bytes
> >      min win adv:            5840 bytes     min win adv:            5792 bytes
> 
> That stinks that the receiver is only using a 64K window,
> that's way too small for gigabit.

Just using the default, no tuning.

I have some patches in the pipeline to do automatic window tuning
based on link speed based on dev->features. But they were actually more 
intended for 10Gbit/s (where all the defaults are completely inadequate)  
And it needs a bit more work. 

-Andi
