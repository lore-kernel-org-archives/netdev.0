From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 23:53:28 +0100
Message-ID: <20050131225328.GI31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <1107186044.1076.11.camel@jzny.localdomain> <20050131155929.GF31837@postel.suug.ch> <1107189625.1076.77.camel@jzny.localdomain> <20050131181553.GG31837@postel.suug.ch> <1107202715.1075.559.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107202715.1075.559.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1107202715.1075.559.camel@jzny.localdomain> 2005-01-31 15:18
> On Mon, 2005-01-31 at 13:15, Thomas Graf wrote:
> 
> > I haven't left ns sim so far, my calculations are based on some of the
> > linux specific cc modifications though, i.e. I modified ns sim a bit
> > to provide the same information. I'm thinking about moving to umlsim,
> > it should provide a better real world simulation.
> > 
> 
> The problem is if theres any bugs in the way algos are implemented in
> Linux you are influenced by that truth. Starting with ns and then
> validating on Linux is a great way to do it.

Absolutely, that's why I first went to ns sim but a nice theory is
worth nothing if it doesn't work in the real world.

> I dont think contrack was designed for this kind of effort. If we totaly
> fail to do it using contrack then we could go a different path.
> sfq already stores some rough view of the state; not sure if it can
> benefit from this.

I was thinking of the parameters to define what a flow consists of.
Extended SFQ basically allows you to define the hash function. I think
I misunderstood you before and you don't want allow adjustable
states on only a subset of the attributes, e.g. only L3 data.

> If you are NATing (stateless) you should enter rules for both
> directions; Maybe we could write a wrapper where user only enters
> outgoing rule and that automatically generates the incoming rule as
> well.

Agreed iff we don't enforce it.

> I think the eactions etc are adding a lot of value towards usability.
> Hasso Tepper was ealrier complaining about this same issue. 
> As an example, I think u32 and ematches would improve a great deal now
> and be more understandable. True, work/time still needs to be invested.

I'd guess that the basic classifier will make the race because the
documentation will be smaller due to the lack of parameters. ;->
But yes I agree, I think we're making small step forwards and hopefully
the network config shell/tool/whatever will ease the steps to configure
things. My primary goal is to allow using it without looking up
parameters all the time, given one is aware of the common terms and basic
concepts. I'll have some more time next week and will try to implement the
traffic control bits or at least some of them. The wind forecast is pretty
good for the next days so I won't have too much time. ;->
