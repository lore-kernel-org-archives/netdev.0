From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 12:22:27 -0700
Message-ID: <432B1B73.2050808@candelatech.com>
References: <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <20050907195911.GA8382@yakov.inr.ac.ru> <20050913221448.GD15704@netnation.com> <20050915210432.GD28925@yakov.inr.ac.ru> <17193.59406.200787.819069@robur.slu.se> <20050915222102.GA30387@yakov.inr.ac.ru> <17194.47097.607795.141059@robur.slu.se> <20050916190404.GA11012@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Simon Kirby <sim@netnation.com>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050916190404.GA11012@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>Yes sounds famliar XEON with e1000... So why not for 2.6?
> 
> 
> Most likely, something is broken in the e1000 driver. Otherwise, no ideas.

Has anyone tried using bridging to compare numbers?  I would assume that
the bridging code is lower-overhead than the routing, so if it's a route
cache problem, the bridge traffic should be significantly higher than
the routed traffic.  If they are both about the same, then either
bridging has lots of overhead too, or the driver (or other network
sub-system) is the bottleneck.

For reference, I was able to bridge only about 200kpps (in each direction, 64 byte pkts)
on a P-IV 3Ghz system with dual Intel e1000 NIC in a PCI-X 64/133 bus....

I would like to hear of any other bridging benchmarks that someone
may have, especially for bi-directional traffic flows.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
