From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: pktgen
Date: Sat, 27 Nov 2004 15:39:23 +0100
Message-ID: <20041127143923.GA25155@xi.wantstofly.org>
References: <20041124161848.GA18059@xi.wantstofly.org> <16804.48120.375307.718766@robur.slu.se> <20041124170948.GC18059@xi.wantstofly.org> <16804.60621.990421.525393@robur.slu.se> <20041125030450.GA24417@xi.wantstofly.org> <16805.40983.937641.670275@robur.slu.se> <20041127002841.GA17184@xi.wantstofly.org> <20041127004325.GA17401@xi.wantstofly.org> <16808.28005.74903.881087@robur.slu.se> <20041127135354.GA24617@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <20041127135354.GA24617@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2004 at 02:53:54PM +0100, Lennert Buytenhek wrote:

> > 160	679270
> 
> From this point onwards your HW can saturate the pipe, this is the
> boring part of the graph.

Look at it this way.  Assume that the cost of transmitting a single
packet consists of a packet-size-dependent part (call it 'bandwidth')
and a packet-size-independent part (call that one 'latency').

The higher the latter part is, the bigger packets you need to saturate
the (GigE) pipe.  

Your 64/133 setup saturates GigE with 160B packets, my 32/66 setup needs
350B packets even though there is ample bandwidth in both cases.

Hope I'm making some sense here.


--L
