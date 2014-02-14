From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add pacing_rate information into tcp_info
Date: Fri, 14 Feb 2014 16:10:07 -0500 (EST)
Message-ID: <20140214.161007.1770559518795699535.davem@davemloft.net>
References: <1392330460.1752.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbaBNVKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:10:09 -0500
In-Reply-To: <1392330460.1752.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Feb 2014 14:27:40 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Add two new fields to struct tcp_info, to report sk_pacing_rate
> and sk_max_pacing_rate to monitoring applications, as ss from iproute2.
> 
> User exported fields are 64bit, even if kernel is currently using 32bit
> fields.
> 
> lpaa5:~# ss -i 
> ..
> 	 skmem:(r0,rb357120,t0,tb2097152,f1584,w1980880,o0,bl0) ts sack cubic
> wscale:6,6 rto:400 rtt:0.875/0.75 mss:1448 cwnd:1 ssthresh:12 send
> 13.2Mbps pacing_rate 3336.2Mbps unacked:15 retrans:1/5448 lost:15
> rcv_space:29200
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
