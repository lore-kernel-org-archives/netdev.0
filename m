From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC] TCP congestion schedulers
Date: 29 Mar 2005 17:25:38 +0200
Message-ID: <20050329152538.GF63268@muc.de>
References: <20050309210442.3e9786a6.davem@davemloft.net> <4230288F.1030202@ev-en.org> <20050310182629.1eab09ec.davem@davemloft.net> <20050311120054.4bbf675a@dxpl.pdx.osdl.net> <20050311201011.360c00da.davem@davemloft.net> <20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu> <20050322074122.GA64595@muc.de> <20050328155117.7c5de370@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>, baruch@ev-en.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 29 Mar 2005 17:25:38 +0200
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050328155117.7c5de370@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Running on 2 Cpu Opteron using netperf loopback mode shows that the change is
> very small when averaged over 10 runs. Overall there is 
> a .28% decrease in CPU usage and a .96% loss in throughput.  But both those
> values are less than twice standard deviation which was .4% for the CPU measurements
> and .8% for the performance measurements.  I can't see it as a worth
> bothering unless there is some big money benchmark on the line, in which case
> it would make more sense to look at other optimizations of the loopback
> path.

Opteron has no problems with indirect calls, IA64 seems to be different
though.

But when you see noticeable differences even on a Opteron I find
it somewhat worrying.

-Andi
