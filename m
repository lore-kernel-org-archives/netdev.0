From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Thu, 20 Jan 2005 18:19:40 +0100
Message-ID: <20050120171940.GJ26856@postel.suug.ch>
References: <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <20050120090628.29205d59@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050120090628.29205d59@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <20050120090628.29205d59@dxpl.pdx.osdl.net> 2005-01-20 09:06
> On Thu, 20 Jan 2005 16:35:59 +0100
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > * jamal <1106232168.1041.125.camel@jzny.localdomain> 2005-01-20 09:42
> > > I like it. Assuming we can have arbitrary hierachies; you just show one
> > > level - but that may be just the example at hand. Given that should be
> > > able to meet the layout requirements that Lennert alluded to earlier.
> > 
> > It doesn't include any context code, the BNF:
> > 
> > PARSER    := TOPNODE*
> > TOPNODE   := NODELIST DESC LONG_DESC
> > NODELIST  := NODE*
> > NODE      := DESC [ NODELIST ] [ ARGUMENT ] [ ATTRS ] [ END_POINT ]
> > END_POINT := possible end of command
> > ATTRS     := ATTR*
> > ATTR      := KEY [ VALUE ]
> > ARGUMENT  := VALUE [ DESC ]
> > 
> > Not sure if this helps, I attached a complete module below.
> > 
> 
> A couple additional suggestions.  It would be great to get a useful API
> to for 'tc' that is one step above actual low level netlink stuff.

Planned. Trying to reuse an existing grammar but didn't found that
suits well enough yet.

> And it would be great to reuse some existing scripting language grammar
> and parsing library infrastructure.

Tried very hard to do so. I'd really like to build upon readline and
its completion method but most parser generators are not made to get along
with readline + completion. A c++ hack exist but doesn't really work
with completion. That's why I wrote my own grammar definition thing.
