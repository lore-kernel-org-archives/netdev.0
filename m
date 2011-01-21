From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: sfq: allow divisor to be a
 parameter
Date: Thu, 20 Jan 2011 16:56:18 -0800 (PST)
Message-ID: <20110120.165618.180427971.davem@davemloft.net>
References: <1295518498.2825.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, hawk@diku.dk,
	jarkao2@gmail.com, hadi@cyberus.ca, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753873Ab1AUAzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:55:43 -0500
In-Reply-To: <1295518498.2825.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jan 2011 11:14:58 +0100

> SFQ currently uses a 1024 slots hash table, and its internal structure
> (sfq_sched_data) allocation needs order-1 page on x86_64
> 
> Allow tc command to specify a divisor value (hash table size), between 1
> and 65536.
> If no value is provided, assume the 1024 default size.
> 
> This allows admins to setup smaller (or bigger) SFQ for specific needs.
> 
> This also brings back sfq_sched_data allocations to order-0 ones, saving
> 3KB per SFQ qdisc.
> 
> Jesper uses ~55.000 SFQ in one machine, this patch should free 165 MB of
> memory.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
