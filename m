From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 29 Mar 2005 14:32:33 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503291422100.3256@dexter.psc.edu>
References: <421D30FA.1060900@ev-en.org> <20050225120814.5fa77b13@dxpl.pdx.osdl.net>
 <20050309210442.3e9786a6.davem@davemloft.net> <4230288F.1030202@ev-en.org>
 <20050310182629.1eab09ec.davem@davemloft.net> <20050311120054.4bbf675a@dxpl.pdx.osdl.net>
 <20050311201011.360c00da.davem@davemloft.net> <20050314151726.532af90d@dxpl.pdx.osdl.net>
 <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
 <20050322074122.GA64595@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, Andi Kleen <ak@muc.de>,
        baruch@ev-en.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050322074122.GA64595@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Mar 2005, Andi Kleen wrote:

> On Mon, Mar 21, 2005 at 04:25:56PM -0500, John Heffner wrote:
> > Is there a canonical benchmark?
>
> For the LSM case we saw the problem with running netperf over loopback.
> It added one or two hooks per packet, but it already made a noticeable
> difference on IA64 boxes.

The motivation for my question is that I get very unpredictable
performance over loopback with UP for all architectures, often varying by
more than a factor of two.  I haven't really tried to track down the
cause, but an important characteristic seems to be that the greater the
differential between the CPU utilization of the sender and the receiver,
the slower the throughput.  (But I'm not sure if there's a causal relation
here.)  Maybe this is simply scheduler strangeness, since it doesn't seem
to be an issue that I've noticed on SMP.  Has anyone seen this or know
offhand what's going on?

The only ia64 I have on which I can boot kernels is a UP box.

  -John
