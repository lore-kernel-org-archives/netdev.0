From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 16:07:23 +0100
Message-ID: <20050118150723.GT26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118143658.GA11474@xi.wantstofly.org> <1106059431.1035.101.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106059431.1035.101.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106059431.1035.101.camel@jzny.localdomain> 2005-01-18 09:43
> On Tue, 2005-01-18 at 09:36, Lennert Buytenhek wrote:
> > On Tue, Jan 18, 2005 at 09:29:52AM -0500, jamal wrote:
> 
> > If you do this, please consider using Juniper config syntax instead
> > of doing it the Cisco/quagga way.
> > 
> 
> Juniper is XML driven config files?
> [I am hoping Thomas would do it, btw;-> only if we strongly disagree
> then i will be tempted to provide an alternative]. 

I'm sure we can find somethign everyone ges along with just fine.
Iff we do the XML thing we might want to try to stick to the ietf
netconf thoughts.

> btw, libio uses libevent; i recall you said you had some alternative to
> it.

libio couldbe put underneath libreadline but it doesn't make much sense,
I think remote shells do the job just fine. I'd favour a XML protocol
like netconf if we want to follow the remote configuration path.
Endianess issues will hit us quite hard though.
