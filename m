From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen
Date: 27 Nov 2004 10:04:22 -0500
Message-ID: <1101567861.1044.87.camel@jzny.localdomain>
References: <20041124161848.GA18059@xi.wantstofly.org>
	 <16804.48120.375307.718766@robur.slu.se>
	 <20041124170948.GC18059@xi.wantstofly.org>
	 <16804.60621.990421.525393@robur.slu.se>
	 <20041125030450.GA24417@xi.wantstofly.org>
	 <16805.40983.937641.670275@robur.slu.se>
	 <20041127002841.GA17184@xi.wantstofly.org>
	 <20041127004325.GA17401@xi.wantstofly.org>
	 <16808.28005.74903.881087@robur.slu.se>
	 <20041127135354.GA24617@xi.wantstofly.org>
	 <20041127143923.GA25155@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041127143923.GA25155@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-11-27 at 09:39, Lennert Buytenhek wrote:

> Look at it this way.  Assume that the cost of transmitting a single
> packet consists of a packet-size-dependent part (call it 'bandwidth')
> and a packet-size-independent part (call that one 'latency').
> 
> The higher the latter part is, the bigger packets you need to saturate
> the (GigE) pipe.  
> 
> Your 64/133 setup saturates GigE with 160B packets, my 32/66 setup needs
> 350B packets even though there is ample bandwidth in both cases.
> 
> Hope I'm making some sense here.

Yes, you are.

Note the constant part of the equation though is not exactly "constant"
even if uyou picked constant hardware. It is per machine (chipset,
topology layout of the bus), per machine setup (how much latency does
your RAM have) and worse: load dependent (two IO endpoints contending
for a PCI-X bridge or the CPU being very busy at the moment with a lot
compute vs RAM-bound execution).
It would be interesting to see a study in this area though.

cheers,
jamal
