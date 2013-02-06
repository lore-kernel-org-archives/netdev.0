From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: reset mac header in dev_start_xmit()
Date: Wed, 06 Feb 2013 15:59:56 -0500 (EST)
Message-ID: <20130206.155956.1647821975614860446.davem@davemloft.net>
References: <1360131740.28557.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab3BFU77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:59:59 -0500
In-Reply-To: <1360131740.28557.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Feb 2013 22:22:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> On 64 bit arches :
> 
> There is a off-by-one error in qdisc_pkt_len_init() because
> mac_header is not set in xmit path.
> 
> skb_mac_header() returns an out of bound value that was
> harmless because hdr_len is an 'unsigned int'
> 
> On 32bit arches, the error is abysmal.
> 
> This patch is also a prereq for "macvlan: add multicast filter"
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
