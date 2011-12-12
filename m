From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netem: add cell concept to simulate special MAC
 behavior
Date: Mon, 12 Dec 2011 09:19:57 -0800
Message-ID: <20111212091957.18660e19@nehalam.linuxnetplumber.net>
References: <1323562110-13865-1-git-send-email-hagen@jauu.net>
	<1323562314-14033-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Florian Westphal <fw@strlen.de>
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36991 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab1LLRUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 12:20:00 -0500
In-Reply-To: <1323562314-14033-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Dec 2011 01:11:54 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

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

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
