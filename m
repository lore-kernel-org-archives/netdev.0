From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Mon, 12 Jul 2004 20:50:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712205037.573411c0.davem@redhat.com>
References: <40F34740.5040100@trash.net>
	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 12 Jul 2004 20:35:16 -0700 (PDT)
shemminger@osdl.org wrote:

> I have a patch (to the original) which replaces the arch dependant CPU stuff
> with the arch neutral sched_clock() which although slightly
> slower works on a x86_64 and ia64 as well.

I also want to add sparc64 %tick register support here too.
This is an area with a lot of potential cleanup.  We should
made an asm/pkt_sched.h to abstract out the clock source
implementation instead of loading net/pkt_sched.h up with
a pile of ifdefs.
