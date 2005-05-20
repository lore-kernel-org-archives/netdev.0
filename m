From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Super TSO
Date: Thu, 19 May 2005 17:45:56 -0700
Message-ID: <428D3344.6090107@hp.com>
References: <200505200015.j4K0FNVG005262@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200505200015.j4K0FNVG005262@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> In this case, 64k TSO becomes a liability and it will make sense to limit it.
>  TSO "sweet spot" will be captured anyways - at least on fast networks, going
>  from 1.5k to 9k typically doubles throughput, while going from 9k to 64k
> adds no more than another 10% (plus a little bit of free %cpu, but not that
> much).


On the surface, that just sounds like something adhering to the laws of
diminishing returns.  As you increase the TSO size, you are shrinking the 
per-send costs, but the per-byte costs (if there is a copy from user to kernel) 
and the ack costs remain the same.

If that 1500 to 9K to 64K is an MTU (and thus real MSS) change than the per-send 
and ack costs are what are diminishing but the per-byte costs remain the same.

Asymptotes and all that...

rick jones
