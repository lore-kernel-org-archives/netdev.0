From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 29 Mar 2005 12:09:20 -0800
Message-ID: <4249B5F0.1050205@hp.com>
References: <421D30FA.1060900@ev-en.org>	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>	<20050309210442.3e9786a6.davem@davemloft.net>	<4230288F.1030202@ev-en.org>	<20050310182629.1eab09ec.davem@davemloft.net>	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>	<20050311201011.360c00da.davem@davemloft.net>	<20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de>	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>	<20050322074122.GA64595@muc.de>	<Pine.LNX.4.58.0503291422100.3256@dexter.psc.edu> <20050329120306.558cea0c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050329120306.558cea0c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> It could be L2 cache-coloring effects as well.  Try to keep the working
> set size smaller than the L2 cache size of the cpu you are on.

When/if using netperf, it will send from and recv to a "ring" of buffers one 
larger than the reported (as opposed to requested) socket buffer size divided by 
the send/recv buffer size.  Controlled via the -W global command-line option.

rick jones
