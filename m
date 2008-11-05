From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] skb_free_datagram() doing something expensive ?
Date: Wed, 05 Nov 2008 01:38:24 -0800 (PST)
Message-ID: <20081105.013824.244777692.davem@davemloft.net>
References: <4910D47E.4030004@cosmosbay.com>
	<49112984.3000808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, minyard@acm.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754229AbYKEJit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:38:49 -0500
In-Reply-To: <49112984.3000808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 05 Nov 2008 06:05:08 +0100

> What we can do is to avoid reclaiming space if forward_alloc is less than a page
> 
> We did that in the past, when introducing sk_mem_reclaim_partial() in commit 9993e7d313e80bdc005d09c7def91903e0068f07
> ([TCP]: Do not purge sk_forward_alloc entirely in tcp_delack_timer())
> 
> This patch gives a nice speedup on UDP, particularly for multiple
> RTP flows, where each flow has a medium trafic (say VOIP trafic)

I like it, patch applied, thanks Eric!
