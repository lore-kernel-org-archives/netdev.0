From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 14:25:19 -0700
Message-ID: <428A613F.1020303@hp.com>
References: <m1k6lx7gkf.fsf@muc.de>	<20050517.132202.59028935.davem@davemloft.net>	<20050517202730.GA79960@muc.de> <20050517.140245.71090021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050517.140245.71090021.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this may be drifting tooo much, but it seems the issue of deciding when to 
give-up on reassembly of an IP datagram is similar to the issues that neterion 
are going to be going-through creating their "LRO" (Large Receive Offload) 
solution, albeit the potential consequences of a bad decision are rather different.

both seek to know when it is unlikely that no more frames/fragments will arrive.

just how much extra overhead would there be to track the interarrival time of ip 
datagram fragments and would that allow someone to make a guess as to how long 
to reasonably wait for all the fragments to arrive? (or did I miss that being 
shot-down already?)

or an added heuristic of "if have reassembled N datagrams for the same 
source/dest/protocol tuple with ID's "larger" than 'this one' since it has 
arrived, we are probably going to wrap so might as well drop 'this one'"  for 
some judicious and magical selection of N that may be a decent predictor of wrap 
on top of some existing reassembly timout.

rick jones
