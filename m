From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: add pkt_type support
Date: Wed, 30 Jan 2013 22:39:02 -0500 (EST)
Message-ID: <20130130.223902.318251097327343709.davem@davemloft.net>
References: <1359597104.30177.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab3AaDjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 22:39:11 -0500
In-Reply-To: <1359597104.30177.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Jan 2013 17:51:44 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Supporting access to skb->pkt_type is a bit tricky if we want
> to have a generic code, allowing pkt_type to be moved in struct sk_buff
> 
> pkt_type is a bit field, so compiler cannot really help us to find
> its offset. Let's use a helper for this : It will throw a one time
> message if pkt_type no longer starts at a byte boundary or is
> no longer a 3bit field.
> 
> Reported-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, although that's quite a hoop to jump through to accomplish
this.
