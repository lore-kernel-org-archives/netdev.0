From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Thu, 20 Jan 2005 09:06:28 -0800
Message-ID: <20050120090628.29205d59@dxpl.pdx.osdl.net>
References: <20050117160539.GD26856@postel.suug.ch>
	<1105979807.1078.16.camel@jzny.localdomain>
	<20050117165626.GE26856@postel.suug.ch>
	<1106002197.1046.19.camel@jzny.localdomain>
	<20050118134406.GR26856@postel.suug.ch>
	<1106058592.1035.95.camel@jzny.localdomain>
	<20050118145830.GS26856@postel.suug.ch>
	<1106144009.1047.989.camel@jzny.localdomain>
	<20050119165421.GB26856@postel.suug.ch>
	<1106232168.1041.125.camel@jzny.localdomain>
	<20050120153559.GG26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050120153559.GG26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 16:35:59 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * jamal <1106232168.1041.125.camel@jzny.localdomain> 2005-01-20 09:42
> > I like it. Assuming we can have arbitrary hierachies; you just show one
> > level - but that may be just the example at hand. Given that should be
> > able to meet the layout requirements that Lennert alluded to earlier.
> 
> It doesn't include any context code, the BNF:
> 
> PARSER    := TOPNODE*
> TOPNODE   := NODELIST DESC LONG_DESC
> NODELIST  := NODE*
> NODE      := DESC [ NODELIST ] [ ARGUMENT ] [ ATTRS ] [ END_POINT ]
> END_POINT := possible end of command
> ATTRS     := ATTR*
> ATTR      := KEY [ VALUE ]
> ARGUMENT  := VALUE [ DESC ]
> 
> Not sure if this helps, I attached a complete module below.
> 



Go for it!

A couple additional suggestions.  It would be great to get a useful API
to for 'tc' that is one step above actual low level netlink stuff.

And it would be great to reuse some existing scripting language grammar
and parsing library infrastructure.


Don't feel constrained to C on this. If using C++ or even something like
phython or ruby would be better go ahead; but please no Perl.

-- 
Stephen Hemminger	<shemminger@osdl.org>
