From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 19 Jan 2005 09:24:26 -0500
Message-ID: <1106144666.1049.994.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118143658.GA11474@xi.wantstofly.org>
	 <1106059431.1035.101.camel@jzny.localdomain>
	 <20050118152017.GA11798@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050118152017.GA11798@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-18 at 10:20, Lennert Buytenhek wrote:
> On Tue, Jan 18, 2005 at 09:43:51AM -0500, jamal wrote:
> 
> > > If you do this, please consider using Juniper config syntax instead
> > > of doing it the Cisco/quagga way.
> > 
> > Juniper is XML driven config files?
> 
> Uhm, no :)  The main advantage over Cisco (IMHO, the last thing I want
> is to start a holy war) is hierarchical config syntax, and the ability
> to commit/rollback all your changes in one go.  It's unfortunately
> rather more verbose, though.

As long as a machine(as opposed to a human) is worrying about the
verbosity - should be fine ;->

>   Example at the bottom.

It has a well defined structure. Do you know if the publish the bnf to
it? Are these guys gonna come after us if we replicate it you think?

> 
> > btw, libio uses libevent; i recall you said you had some alternative to
> > it.
> 
> Yeah, ivykis (http://libivykis.sourceforge.net/) has been happily used
> in-house at my last job for years but never really caught on anywhere
> else, which is perhaps because I never did much lobbying for it.  The
> way it works also requires all code written for it to be fully async
> (can't use blocking code anywhere), which I think is an advantage but
> everyone else thinks is a disadvantage.

very similar to libevent. I am gonna start using yours because then i
could send you emails which start with "Dear sir, .. i have doubts
because it doesnt work" ;->

cheers,
jamal
