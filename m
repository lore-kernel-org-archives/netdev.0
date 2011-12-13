From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: add cell concept to simulate special MAC
 behavior
Date: Mon, 12 Dec 2011 19:45:12 -0500 (EST)
Message-ID: <20111212.194512.338764506478752885.davem@davemloft.net>
References: <20111212.190132.2127710068935598402.davem@davemloft.net>
	<1323736200-1252-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab1LMApU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 19:45:20 -0500
In-Reply-To: <1323736200-1252-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue, 13 Dec 2011 01:30:00 +0100

> This extension can be used to simulate special link layer
> characteristics. Simulate because packet data is not modified, only the
> calculation base is changed to delay a packet based on the original
> packet size and artificial cell information.
> 
> packet_overhead can be used to simulate a link layer header compression
> scheme (e.g. set packet_overhead to -20) or with a positive
> packet_overhead value an additional MAC header can be simulated. It is
> also possible to "replace" the 14 byte Ethernet header with something
> else.
> 
> cell_size and cell_overhead can be used to simulate link layer schemes,
> based on cells, like some TDMA schemes. Another application area are MAC
> schemes using a link layer fragmentation with a (small) header each.
> Cell size is the maximum amount of data bytes within one cell. Cell
> overhead is an additional variable to change the per-cell-overhead
> (e.g.  5 byte header per fragment).
> 
> Example (5 kbit/s, 20 byte per packet overhead, cell-size 100 byte, per
> cell overhead 5 byte):
> 
>   tc qdisc add dev eth0 root netem rate 5kbit 20 100 5
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
