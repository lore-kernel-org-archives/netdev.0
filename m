From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] TCP congestion schedulers
Date: Mon, 21 Mar 2005 16:25:56 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
References: <421CF5E5.1060606@ev-en.org> <20050223135732.39e62c6c.davem@davemloft.net>
 <421D1E66.5090301@osdl.org> <421D30FA.1060900@ev-en.org>
 <20050225120814.5fa77b13@dxpl.pdx.osdl.net> <20050309210442.3e9786a6.davem@davemloft.net>
 <4230288F.1030202@ev-en.org> <20050310182629.1eab09ec.davem@davemloft.net>
 <20050311120054.4bbf675a@dxpl.pdx.osdl.net> <20050311201011.360c00da.davem@davemloft.net>
 <20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m13bur5qyo.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Mar 2005, Andi Kleen wrote:

> Stephen Hemminger <shemminger@osdl.org> writes:
>
> > Since developers want to experiment with different congestion
> > control mechanisms, and the kernel is getting bloated with overlapping
> > data structure and code for multiple algorithms; here is a patch to
> > split out the Reno, Vegas, Westwood, BIC congestion control stuff
> > into an infrastructure similar to the I/O schedulers.
>
> [...]
>
> Did you do any benchmarks to check that wont slow it down?
>
> I would recommend to try it on a IA64 machine if possible. In the
> past we found that adding indirect function calls on IA64 to networking
> caused measurable slowdowns in macrobenchmarks.
> In that case it was LSM callbacks, but your code looks like it will
> add even more.

Is there a canonical benchmark?

Would you really expect a single extra indirect call per ack to have a
significant performance impact?  This is surprising to me.  Where does the
cost come from?  Replacing instruction cache lines?

  -John
