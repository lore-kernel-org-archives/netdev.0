From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 29 Mar 2005 09:17:25 -0800
Message-ID: <20050329091725.4f955ee7@dxpl.pdx.osdl.net>
References: <20050309210442.3e9786a6.davem@davemloft.net>
	<4230288F.1030202@ev-en.org>
	<20050310182629.1eab09ec.davem@davemloft.net>
	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	<20050311201011.360c00da.davem@davemloft.net>
	<20050314151726.532af90d@dxpl.pdx.osdl.net>
	<m13bur5qyo.fsf@muc.de>
	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
	<20050322074122.GA64595@muc.de>
	<20050328155117.7c5de370@dxpl.pdx.osdl.net>
	<20050329152538.GF63268@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, baruch@ev-en.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050329152538.GF63268@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Mar 2005 17:25:38 +0200
Andi Kleen <ak@muc.de> wrote:

> > Running on 2 Cpu Opteron using netperf loopback mode shows that the change is
> > very small when averaged over 10 runs. Overall there is 
> > a .28% decrease in CPU usage and a .96% loss in throughput.  But both those
> > values are less than twice standard deviation which was .4% for the CPU measurements
> > and .8% for the performance measurements.  I can't see it as a worth
> > bothering unless there is some big money benchmark on the line, in which case
> > it would make more sense to look at other optimizations of the loopback
> > path.
> 
> Opteron has no problems with indirect calls, IA64 seems to be different
> though.

Getting IA64 setup today, to check.

> But when you see noticeable differences even on a Opteron I find
> it somewhat worrying.

The difference was so tiny that it is in the noise of the measurements.
