From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: don't reallocate skb->head unless the current
 one hasn't the needed extra size or is shared
Date: Fri, 03 Dec 2010 09:47:39 -0800 (PST)
Message-ID: <20101203.094739.35049271.davem@davemloft.net>
References: <1291106926-1898-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759Ab0LCRrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:47:12 -0500
In-Reply-To: <1291106926-1898-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 30 Nov 2010 16:48:46 +0800

> skb head being allocated by kmalloc(), it might be larger than what
> actually requested because of discrete kmem caches sizes. Before
> reallocating a new skb head, check if the current one has the needed
> extra size.
> 
> Do this check only if skb head is not shared.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Eric, ACK?
