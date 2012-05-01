From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Mon, 30 Apr 2012 21:48:31 -0400 (EDT)
Message-ID: <20120430.214831.1079448543357914010.davem@davemloft.net>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	<1335809434.2296.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	mcarlson@broadcom.com, herbert@gondor.hengli.com.au,
	bhutchings@solarflare.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757762Ab2EABst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:48:49 -0400
In-Reply-To: <1335809434.2296.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Apr 2012 20:10:34 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> GRO can check if skb to be merged has its skb->head mapped to a page
> fragment, instead of a kmalloc() area.
> 
> We 'upgrade' skb->head as a fragment in itself
> 
> This avoids the frag_list fallback, and permits to build true GRO skb
> (one sk_buff and up to 16 fragments), using less memory.
> 
> This reduces number of cache misses when user makes its copy, since a
> single sk_buff is fetched.
> 
> This is a followup of patch "net: allow skb->head to be a page fragment"
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
