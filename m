From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Thu, 22 Jul 2004 17:17:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722171752.341d2476.davem@redhat.com>
References: <40F34740.5040100@trash.net>
	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
	<20040712205037.573411c0.davem@redhat.com>
	<40F4862D.3070802@trash.net>
	<40F4AC8B.40706@trash.net>
	<20040721143110.4ab944bf.davem@redhat.com>
	<41004F76.1080807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41004F76.1080807@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 01:36:22 +0200
Patrick McHardy <kaber@trash.net> wrote:

> > I suggest we just expand the dependency list for NET_SCH_CLK_TSC
> > to include SPARC64 PPC64 and perhaps some other easy to verify
> > as having a working get_cycles() implementation.  I believe that
> > as long as it increments at some rate >= jiffies, the psched
> > calibration will get things into a working state.
> 
> It needs to increment at slightly above 1Mhz, otherwise delay will
> be zero after this division and everything will fall apart:
> delay /= rdelay.

I see.  I know for a fact that sparc64 meets this criterion, and
I'm pretty sure ppc64 does too.

We could bug check this in psched calibration, in fact I think
we should.
