From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Tue, 21 Sep 2004 11:04:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921090423.GE8058@wotan.suse.de>
References: <20040918203319.24004d6e.davem@davemloft.net> <1095645106.1048.190.camel@jzny.localdomain> <20040919195351.0b3560e6.davem@davemloft.net> <1095686672.1049.301.camel@jzny.localdomain> <20040920121123.70baf895.davem@davemloft.net> <20040921034212.GA28462@gondor.apana.org.au> <20040920231805.3f18479c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040920231805.3f18479c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 11:18:05PM -0700, David S. Miller wrote:
> On Tue, 21 Sep 2004 13:42:12 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Mon, Sep 20, 2004 at 07:11:23PM +0000, David S. Miller wrote:
> > > 
> > > I believe I was successful in preserving existing behavior, but
> > > I wonder if it makes sense any longer.  CONFIG_IP_ROUTE_TOS
> > > changes not one data structure.  It does exactly:
> > 
> > Yes CONFIG_IP_ROUTE_TOS has out-lived its usefulness.  It has
> > always seemed half-hearted compared to CONFIG_IP_ROUTE_FWMARK.
> 
> Ok, then I'm gonna nuke it.

Hmm, are you removing TOS support completely or just remove the
CONFIG and always enable the code? 

[Somehow it looks to me like you and Herbert are miscommunicating ;-]

I think you should remove the TOS support completely because
it's obsolete with fwmark.  And maybe remove it will allow
some tuning later.

-Andi
