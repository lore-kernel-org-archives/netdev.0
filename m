From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5 net-next] net: makes skb_splice_bits() aware of
 skb->head_frag
Date: Mon, 30 Apr 2012 21:48:55 -0400 (EDT)
Message-ID: <20120430.214855.1985836626684393490.davem@davemloft.net>
References: <1335528603.2775.246.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	jeffrey.t.kirsher@intel.com, therbert@google.com,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com,
	mcarlson@broadcom.com, mchan@broadcom.com, maze@google.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757910Ab2EABtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:49:12 -0400
In-Reply-To: <1335528603.2775.246.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Apr 2012 14:10:03 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> __skb_splice_bits() can check if skb to be spliced has its skb->head
> mapped to a page fragment, instead of a kmalloc() area.
> 
> If so we can avoid a copy of the skb head and get a reference on
> underlying page.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
