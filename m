From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: splice: avoid high order page splitting
Date: Sun, 06 Jan 2013 21:07:43 -0800 (PST)
Message-ID: <20130106.210743.46446075597784928.davem@davemloft.net>
References: <1357438591.1678.5205.camel@edumazet-glaptop>
	<20130106025256.GY16031@1wt.eu>
	<1357457478.1678.5928.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3AGFHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:07:43 -0500
In-Reply-To: <1357457478.1678.5928.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Jan 2013 23:31:18 -0800

> From: Eric Dumazet <edumazet@google.com>
>  
> splice() can handle pages of any order, but network code tries hard to
> split them in PAGE_SIZE units. Not quite successfully anyway, as
> __splice_segment() assumed poff < PAGE_SIZE. This is true for
> the skb->data part, not necessarily for the fragments.
> 
> This patch removes this logic to give the pages as they are in the skb.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
