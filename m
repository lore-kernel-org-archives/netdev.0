From: Jason Lunz <lunz@falooley.org>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Fri, 28 Mar 2003 17:32:08 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb891ov.mf8.lunz@stoli.localnet>
References: <16003.11449.497905.815776@robur.slu.se> <slrnb86c3g.7vo.lunz@stoli.localnet> <16004.1914.582979.278009@robur.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert.Olsson@data.slu.se said:
>  Can you test the patch I sent for 5.0.43 with your equipment/setup?

We have a winner! I called the driver with your patch 5.0.43-k1-ro1. I
also removed all the cyclesoak lines; all they really show is that
throughput is really sensitive to how much CPU time ksoftirqd gets.

http://gtf.org/lunz/linux/net/perf/ is still the url.

Jason
