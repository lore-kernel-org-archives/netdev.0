From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] Improve UDP multicast receive latency
Date: Tue, 08 Oct 2013 16:51:47 -0400 (EDT)
Message-ID: <20131008.165147.1204109363656237950.davem@davemloft.net>
References: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomk@rgmadvisors.com,
	eric.dumazet@gmail.com, sbohrer@rgmadvisors.com
To: shawn.bohrer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab3JHUvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:51:48 -0400
In-Reply-To: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <shawn.bohrer@gmail.com>
Date: Mon,  7 Oct 2013 11:01:37 -0500

> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> The removal of the routing cache in 3.6 had impacted the latency of our
> UDP multicast workload.  This patch series brings down the latency to
> what we were seeing with 3.4.
> 
> Patch 1 "udp: Only allow busy read/poll on connected sockets" is mostly
> done for correctness and because it allows unifying the unicast and
> multicast paths when a socket is found in early demux.  It can also
> improve latency for a connected multicast socket if busy read/poll is
> used.
> 
> Patches 2&3 remove the fib lookups and restore latency for our workload
> to the pre 3.6 levels.
> 
> Benchmark results from a netperf UDP_RR test:
> v3.12-rc3-447-g40dc9ab kernel   87961.22 transactions/s
> v3.12-rc3-447-g40dc9ab + series 90587.62 transactions/s
> 
> Benchmark results from a fio 1 byte UDP multicast pingpong test
> (Multicast one way unicast response):
> v3.12-rc3-447-g40dc9ab kernel   12.97us RTT
> v3.12-rc3-447-g40dc9ab + series 12.48us RTT

Great work, all applied to net-next, thanks!
