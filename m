From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 20 May 2005 15:52:20 -0700
Message-ID: <428E6A24.7060403@hp.com>
References: <1116031159.6214.8.camel@rh4>	<20050513.222007.78719997.davem@davemloft.net>	<Pine.LNX.4.61.0505201442380.11419@linux.site> <20050520.153326.08322399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050520.153326.08322399.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Yes, but using such a high value makes latency go into the
> toilet. :-)

For low packet rates.

> 
> I'd much rather see dynamic settings based upon packet rate.
> It's easy to resurrect the ancient code from the early
> tg3 days which does this.

If that is the stuff I think it was, it was giving me _fits_ trying to run 
TCP_RR tests.  Results bounced all over the place.  I think it was trying to 
kick-in at pps rates that were below the limits of what a pair of systems could 
do on a single, synchronous request/response stream.


Now, modulo an OS that I cannot mention because its EULA forbits discussing 
results with third parties, where the netperf TCP_RR perf is 8000 transactions 
per second no matter how powerful the CPU...   if folks are simply free to set 
high coalescing parms on their own, presumably with some knowledge of their 
workloads, wouldn't that be enough?  That has been "good enough" for one OS I 
can discuss - HP-UX - and its bcm570X-based GbE NICs and before to Tigon2.

rick jones
