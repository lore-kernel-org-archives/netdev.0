From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
 sfq_dump_class_stats()
Date: Mon, 20 Dec 2010 13:14:11 -0800 (PST)
Message-ID: <20101220.131411.48502440.davem@davemloft.net>
References: <4D08F91C.4070000@trash.net>
	<1292434227.3427.377.camel@edumazet-laptop>
	<1292437116.3427.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933186Ab0LTVNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 16:13:42 -0500
In-Reply-To: <1292437116.3427.386.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Dec 2010 19:18:36 +0100

> We currently return for each active SFQ slot the number of packets in
> queue. We can also give number of bytes accounted for these packets.
> 
> tc -s class show dev ifb0
> 
> Before patch :
> 
> class sfq 11:3d9 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 3p requeues 0 
>  allot 1266 
> 
> After patch :
> 
> class sfq 11:3e4 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 4380b 3p requeues 0 
>  allot 1212 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
