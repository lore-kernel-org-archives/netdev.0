From: Jason Lunz <lunz@falooley.org>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Thu, 27 Mar 2003 17:10:03 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb86c3g.7vo.lunz@stoli.localnet>
References: <16003.11449.497905.815776@robur.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert.Olsson@data.slu.se said:
> 10 Million pkts injected at high speed into eth2 and forwarded to eth3. Rx and 
> Tx buffers are 256 and HW_FLOW is disabled and RxIntDelay=1. Which is same 
> parameters as we use for production systems. As seen link now flaps. 
> Eventually can hw_flowcontrol and interrupt delays help this... but thats not 
> an option at least not for us. 
> 
> 
> Twist:        New                        Old
>              ====================================
> Input rate:    680 (due to link drop)    820 kpps
> T-put:         309                       385 kpps 
> RX irq's:    78963                       434

I've seen pretty much the same thing. I plotted throughput vs. offered
load for e1000 4.4.12-k1, 4.4.19-k3, and 5.0.43-k1 (all backported to
2.4.20). A summary with graphs is at:

http://gtf.org/lunz/linux/net/perf/

5.0.43 seems to be a significant regression, both in terms of throughput
and CPU load.

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/
