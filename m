From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Wed, 21 Jul 2004 14:31:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721143110.4ab944bf.davem@redhat.com>
References: <40F34740.5040100@trash.net>
	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
	<20040712205037.573411c0.davem@redhat.com>
	<40F4862D.3070802@trash.net>
	<40F4AC8B.40706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40F4AC8B.40706@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jul 2004 05:46:19 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This one actually compiles ;). The assembler of PSCHED_GET_TIME is
> exactly the same on x86. There are 10 architectures that return
> something non-zero for get_cycles(), but I have no idea if it is
> suitable on all of them. Patch applies on top of the dead-code
> removal patch.

This looks great.

As you mention some platforms return zero, for example sparc32,
for get_cycles().

I suggest we just expand the dependency list for NET_SCH_CLK_TSC
to include SPARC64 PPC64 and perhaps some other easy to verify
as having a working get_cycles() implementation.  I believe that
as long as it increments at some rate >= jiffies, the psched
calibration will get things into a working state.

A lot of patches have been posted in this area and I'm losing
track of what to apply first etc.  Can you repost your work
one change at a time?  Thanks.
