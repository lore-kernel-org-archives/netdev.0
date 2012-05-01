From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Mon, 30 Apr 2012 21:48:07 -0400 (EDT)
Message-ID: <20120430.214807.1812829266907342907.davem@davemloft.net>
References: <1335522818.2775.227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	ncardwell@google.com, therbert@google.com, maze@google.com,
	jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab2EABs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:48:28 -0400
In-Reply-To: <1335522818.2775.227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Apr 2012 12:33:38 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> skb->head is currently allocated from kmalloc(). This is convenient but
> has the drawback the data cannot be converted to a page fragment if
> needed.
 ...
> Given all these issues, the following patch introduces the possibility
> of having skb->head be a fragment in itself. We use a new skb flag,
> skb->head_frag to carry this information.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
