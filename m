From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 29 Mar 2005 12:03:06 -0800
Message-ID: <20050329120306.558cea0c.davem@davemloft.net>
References: <421D30FA.1060900@ev-en.org>
	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	<20050309210442.3e9786a6.davem@davemloft.net>
	<4230288F.1030202@ev-en.org>
	<20050310182629.1eab09ec.davem@davemloft.net>
	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	<20050311201011.360c00da.davem@davemloft.net>
	<20050314151726.532af90d@dxpl.pdx.osdl.net>
	<m13bur5qyo.fsf@muc.de>
	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
	<20050322074122.GA64595@muc.de>
	<Pine.LNX.4.58.0503291422100.3256@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, ak@muc.de, baruch@ev-en.org
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0503291422100.3256@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Mar 2005 14:32:33 -0500 (EST)
John Heffner <jheffner@psc.edu> wrote:

> The motivation for my question is that I get very unpredictable
> performance over loopback with UP for all architectures, often varying by
> more than a factor of two.  I haven't really tried to track down the
> cause, but an important characteristic seems to be that the greater the
> differential between the CPU utilization of the sender and the receiver,
> the slower the throughput.  (But I'm not sure if there's a causal relation
> here.)  Maybe this is simply scheduler strangeness, since it doesn't seem
> to be an issue that I've noticed on SMP.  Has anyone seen this or know
> offhand what's going on?

It could be L2 cache-coloring effects as well.  Try to keep the working
set size smaller than the L2 cache size of the cpu you are on.
